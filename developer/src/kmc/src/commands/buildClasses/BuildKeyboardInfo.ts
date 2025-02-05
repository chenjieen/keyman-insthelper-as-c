import * as fs from 'fs';
import { BuildActivity } from './BuildActivity.js';
import { CompilerCallbacks, KeymanFileTypes } from '@keymanapp/common-types';
import { KeyboardInfoCompiler } from '@keymanapp/kmc-keyboard-info';
import { loadProject } from '../../util/projectLoader.js';
import { InfrastructureMessages } from '../../messages/infrastructureMessages.js';
import { calculateSourcePath } from '../../util/calculateSourcePath.js';
import { getLastGitCommitDate } from '../../util/getLastGitCommitDate.js';
import { ExtendedCompilerOptions } from 'src/util/extendedCompilerOptions.js';

export class BuildKeyboardInfo extends BuildActivity {
  public get name(): string { return 'Keyboard metadata'; }
  public get sourceExtension(): KeymanFileTypes.Source { return KeymanFileTypes.Source.Project; }
  public get compiledExtension(): KeymanFileTypes.Binary { return KeymanFileTypes.Binary.KeyboardInfo; }
  public get description(): string { return 'Build a keyboard metadata file'; }
  public async build(infile: string, callbacks: CompilerCallbacks, options: ExtendedCompilerOptions): Promise<boolean> {
    if(!KeymanFileTypes.filenameIs(infile, KeymanFileTypes.Source.Project)) {
      // Even if the project file does not exist, we use its name as our reference
      // in order to avoid ambiguity
      throw new Error(`BuildKeyboardInfo called with unexpected file type ${infile}`);
    }

    const project = loadProject(infile, callbacks);
    if(!project) {
      // Error messages written by loadProject
      return false;
    }

    const kps = project.files.find(file => file.fileType == KeymanFileTypes.Source.Package);
    if(!kps)  {
      callbacks.reportMessage(InfrastructureMessages.Error_FileTypeNotFound({ext: KeymanFileTypes.Source.Package}));
      return false;
    }

    const keyboard = project.files.find(file => file.fileType == KeymanFileTypes.Source.KeymanKeyboard);
    const jsFilename = keyboard ? project.resolveOutputFilePath(keyboard, KeymanFileTypes.Source.KeymanKeyboard, KeymanFileTypes.Binary.WebKeyboard) : null;
    const lastCommitDate = getLastGitCommitDate(project.projectPath);

    const compiler = new KeyboardInfoCompiler(callbacks);
    const data = await compiler.writeKeyboardInfoFile({
      kmpFilename:  project.resolveOutputFilePath(kps, KeymanFileTypes.Source.Package, KeymanFileTypes.Binary.Package),
      kpsFilename: project.resolveInputFilePath(kps),
      jsFilename: jsFilename && fs.existsSync(jsFilename) ? jsFilename : undefined,
      sourcePath: calculateSourcePath(infile),
      lastCommitDate,
      forPublishing: !!options.forPublishing,
    });

    if(data == null) {
      // Error messages have already been emitted by KeyboardInfoCompiler
      return false;
    }

    const outputFilename = project.getOutputFilePath(KeymanFileTypes.Binary.KeyboardInfo);

    fs.writeFileSync(
      outputFilename,
      data
    );

    return true;
  }
}
