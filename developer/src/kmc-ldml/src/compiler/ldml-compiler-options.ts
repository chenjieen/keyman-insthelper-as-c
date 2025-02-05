import { CompilerOptions, LDMLKeyboardXMLSourceFileReaderOptions } from "@keymanapp/common-types";

export interface LdmlCompilerOptions extends CompilerOptions {
  /**
   * Paths and other options required for reading .xml files
   */
  readerOptions: LDMLKeyboardXMLSourceFileReaderOptions;
};
