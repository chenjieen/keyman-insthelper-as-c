import { KmnCompilerMessages } from "../compiler/kmn-compiler-messages.js";
import { CompilerErrorNamespace, CompilerErrorSeverity, CompilerEvent, CompilerMessageSpec } from "@keymanapp/common-types";
import { kmnfile } from "./compiler-globals.js";

const Namespace = CompilerErrorNamespace.KmwCompiler;
// const SevInfo = CompilerErrorSeverity.Info | Namespace;
// const SevHint = CompilerErrorSeverity.Hint | Namespace;
// const SevWarn = CompilerErrorSeverity.Warn | Namespace;
const SevError = CompilerErrorSeverity.Error | Namespace;
// const SevFatal = CompilerErrorSeverity.Fatal | Namespace;

const m = (code: number, message: string, o?: {e?: any, filename?: string, line?: number}) : CompilerEvent => ({
  ...CompilerMessageSpec(code, message, o?.e),
  filename: o?.filename ?? kmnfile,
  line: o?.line,
});

export class KmwCompilerMessages extends KmnCompilerMessages {
  // Note: for legacy reasons, KMWCompilerMessages extends from
  // KMNCompilerMessages as they share the same error codes. This can be a
  // little confusing because kmcmplib still builds its own error message
  // strings, not kmc-kmn, whereas the kmw messages are defined here. However,
  // as the kmw module may be going away at some point, it's probably not worth
  // the splitting of all KMW-specific error messages out of the
  // KmnCompilerMessages space.

  static Error_InvalidBegin = () => m(this.ERROR_InvalidBegin,
    `A "begin unicode" statement is required to compile a KeymanWeb keyboard`);

  static Error_InvalidTouchLayoutFile = (o:{filename:string}) => m(this.ERROR_InvalidTouchLayoutFile,
    `Touch layout file ${o.filename} is not valid`);

  static Warn_DontMixChiralAndNonChiralModifiers = () => m(this.WARN_DontMixChiralAndNonChiralModifiers,
    `This keyboard contains Ctrl,Alt and LCtrl,LAlt,RCtrl,RAlt sets of modifiers. Use only one or the other set for web target.`);

  static Warn_OptionStoreNameInvalid = (o:{name:string}) => m(this.WARN_OptionStoreNameInvalid,
    `The option store ${o.name} should be named with characters in the range A-Z, a-z, 0-9 and _ only.`);

  static Error_VirtualCharacterKeysNotSupportedInKeymanWeb = (o:{line:number}) => m(this.ERROR_VirtualCharacterKeysNotSupportedInKeymanWeb,
    `Virtual character keys not currently supported in KeymanWeb`, o);

  static Error_VirtualKeysNotValidForMnemonicLayouts = (o:{line:number}) => m(this.ERROR_VirtualKeysNotValidForMnemonicLayouts,
    `Virtual keys are not valid for mnemonic layouts`, o);

  static Warn_ExtendedShiftFlagsNotSupportedInKeymanWeb = (o:{line:number,flags:string}) => m(this.WARN_ExtendedShiftFlagsNotSupportedInKeymanWeb,
    `Extended shift flags ${o.flags} are not supported in KeymanWeb`, o);

  static Hint_UnreachableKeyCode = (o:{line:number,key:string}) => m(this.HINT_UnreachableKeyCode,
    `The rule will never be matched for key ${o.key} because its key code is never fired.`, o);

  static Error_NotSupportedInKeymanWebStore = (o:{code:string,store:string}) => m(this.ERROR_NotSupportedInKeymanWebStore,
    `'${o.code}' is not currently supported in store '${o.store}' when used by any or index for web and touch targets`);

  static Error_NotSupportedInKeymanWebContext = (o:{line:number, code:String}) => m(this.ERROR_NotSupportedInKeymanWebContext,
    `Statement '${o.code}' is not currently supported in context for web and touch targets`, o);

  static Error_NotSupportedInKeymanWebOutput = (o:{line:number, code:string}) => m(this.ERROR_NotSupportedInKeymanWebOutput,
    `Statement '${o.code}' is not currently supported in output for web and touch targets`, o);

  static Warn_HelpFileMissing = (o:{line:number, helpFilename:string, e:any}) => m(this.WARN_HelpFileMissing,
    `File ${o.helpFilename} could not be loaded: ${(o.e??'').toString()}`,o);

  static Warn_EmbedJsFileMissing = (o:{line:number, jsFilename: string, e:any}) => m(this.WARN_EmbedJsFileMissing,
    `File ${o.jsFilename} could not be loaded: ${(o.e??'').toString()}`, o);

  static Warn_TouchLayoutMissingLayer = (o:{keyId:string, platformName:string, layerId:string, nextLayer:string}) => m(this.WARN_TouchLayoutMissingLayer,
    `Key "${o.keyId}" on platform "${o.platformName}", layer "${o.layerId}", references a missing layer "${o.nextLayer}"`);

  static Warn_TouchLayoutUnidentifiedKey = (o:{layerId:string}) => m(this.WARN_TouchLayoutUnidentifiedKey,
    `A key on layer "${o.layerId}" has no identifier.`);

  static Error_TouchLayoutInvalidIdentifier = (o:{keyId:string, platformName: string, layerId:string}) => m(this.ERROR_TouchLayoutInvalidIdentifier,
    `Key "${o.keyId}" on "${o.platformName}", layer "${o.layerId}" has an invalid identifier.`);

  static Warn_TouchLayoutCustomKeyNotDefined = (o:{keyId:string, platformName:string, layerId:string}) => m(this.WARN_TouchLayoutCustomKeyNotDefined,
    `Key "${o.keyId}" on platform "${o.platformName}", layer "${o.layerId}", is a custom key but has no corresponding rule in the source.`);

  static Warn_TouchLayoutSpecialLabelOnNormalKey = (o:{keyId:string, platformName:string, layerId:string, label:string}) =>
    m(this.WARN_TouchLayoutSpecialLabelOnNormalKey,
    `Key "${o.keyId}" on platform "${o.platformName}", layer "${o.layerId}" does not have `+
    `the key type "Special" or "Special (active)" but has the label "${o.label}". This feature is only supported in Keyman 14 or later`);

  static Error_InvalidKeyCode = (o:{keyId: string}) => m(this.ERROR_InvalidKeyCode,
    `Invalid key identifier "${o.keyId}"`);

  static Warn_TouchLayoutFontShouldBeSameForAllPlatforms = () => m(this.WARN_TouchLayoutFontShouldBeSameForAllPlatforms,
    `The touch layout font should be the same for all platforms.`);

  static Warn_TouchLayoutMissingRequiredKeys = (o:{layerId:string, platformName:string, missingKeys:string}) => m(this.WARN_TouchLayoutMissingRequiredKeys,
    `Layer "${o.layerId}" on platform "${o.platformName}" is missing the required key(s) '${o.missingKeys}'.`);

  // Following messages are kmw-compiler only, so use KmwCompiler error namespace

  static Error_NotAnyRequiresVersion14 = (o:{line: number}) => m(this.ERROR_NotAnyRequiresVersion14,
    `Statement notany in context() match requires version 14.0+ of KeymanWeb`, o);
  static ERROR_NotAnyRequiresVersion14 = SevError | 0x0001;

  static Error_TouchLayoutIdentifierRequires15 = (o:{keyId:string, platformName:string, layerId:string}) => m(this.ERROR_TouchLayoutIdentifierRequires15,
    `Key "${o.keyId}" on "${o.platformName}", layer "${o.layerId}" has a multi-part identifier which requires version 15.0 or newer.`);
  static ERROR_TouchLayoutIdentifierRequires15 = SevError | 0x0002;

  static Error_InvalidTouchLayoutFileFormat = (o:{msg: string}) => m(this.ERROR_InvalidTouchLayoutFileFormat,
    `Invalid touch layout file: ${o.msg}`);
  static ERROR_InvalidTouchLayoutFileFormat = SevError | 0x0003;

  static Error_TouchLayoutFileDoesNotExist = (o:{filename:string}) => m(this.ERROR_TouchLayoutFileDoesNotExist,
    `Touch layout file ${o.filename} does not exist`);
  static ERROR_TouchLayoutFileDoesNotExist = SevError | 0x0004;
};
