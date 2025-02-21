import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Basic Types
base class SHStringWithLen extends Struct {
  external Pointer<Utf8> string;
  @Uint64()
  external int len;
}

// Enums
class SHType {
  static const None = 0;
  static const Any = 1;
  static const Enum = 2;
  static const Bool = 3;
  static const Int = 4;
  static const Int2 = 5;
  static const Int3 = 6;
  static const Int4 = 7;
  static const Int8 = 8;
  static const Int16 = 9;
  static const Float = 10;
  static const Float2 = 11;
  static const Float3 = 12;
  static const Float4 = 13;
  static const Color = 14;
  static const EndOfBlittableTypes = 50;
  static const Bytes = 51;
  static const String = 52;
  static const Path = 53;
  static const ContextVar = 54;
  static const Image = 55;
  static const Seq = 56;
  static const Table = 57;
  static const Wire = 58;
  static const ShardRef = 59;
  static const Object = 60;
  static const Audio = 63;
  static const Type = 64;
  static const Trait = 65;
}

class SHWireState {
  static const Continue = 0;
  static const Return = 1;
  static const Rebase = 2;
  static const Restart = 3;
  static const Stop = 4;
  static const Error = 5;
}

// Basic Types
base class SHColor extends Struct {
  @Uint8()
  external int r;
  @Uint8()
  external int g;
  @Uint8()
  external int b;
  @Uint8()
  external int a;
}

// Payload Union
base class SHVarPayload extends Union {
  external Pointer<Void> objectValue;
  @Int64()
  external int intValue;
  @Array(2)
  external Array<Int64> int2Value;
  @Array(3)
  external Array<Int32> int3Value;
  @Array(4)
  external Array<Int32> int4Value;
  @Array(8)
  external Array<Int16> int8Value;
  @Array(16)
  external Array<Int8> int16Value;

  @Double()
  external double floatValue;
  @Array(2)
  external Array<Double> float2Value;
  @Array(3)
  external Array<Float> float3Value;
  @Array(4)
  external Array<Float> float4Value;

  external Pointer<Utf8> stringValue;
  @Uint32()
  external int stringLen;
  @Uint32()
  external int stringCapacity;

  external SHColor colorValue;
  external Pointer<Void> imageValue;
  external Pointer<Void> audioValue;
  external Pointer<Void> wireValue;
  external Pointer<Void> shardValue;

  // Add other payload fields as needed
}

// SHVar Structure
base class SHVar extends Struct {
  external SHVarPayload payload;
  external Pointer<Void> objectInfo;
  @Uint8()
  external int valueType;
  @Uint8()
  external int innerType;
  @Uint16()
  external int flags;
  @Uint32()
  external int refcount;
}

// Core Interface Functions
typedef SHCoreNative = Pointer<SHCore> Function(Uint32 abi_version);
typedef SHCoreDart = Pointer<SHCore> Function(int abi_version);

final shardsInterface = shardsLib.lookupFunction<SHCoreNative, SHCoreDart>(
  'shardsInterface',
);

// Additional typedefs needed for SHCore
typedef SHAlloc = Pointer<Void> Function(Uint32 size);
typedef SHFree = Void Function(Pointer<Void> ptr);
typedef SHTableNew = Pointer<Void> Function();
typedef SHSetRootPath = Void Function(Pointer<Utf8> path);
typedef SHGetRootPath = Pointer<Utf8> Function();
typedef SHImageIncRef = Void Function(Pointer<Void> image);
typedef SHImageDecRef = Void Function(Pointer<Void> image);
typedef SHImageNew = Pointer<Void> Function(Uint32 dataLen);
typedef SHImageClone = Pointer<Void> Function(Pointer<Void> image);
typedef SHImageDeriveDataLength = Uint32 Function(Pointer<Void> image);

// Array operation typedefs
typedef SHSeqFree = Void Function(Pointer<Void> seq);
typedef SHSeqPush = Void Function(Pointer<Void> seq, Pointer<SHVar> item);
typedef SHSeqInsert =
    Void Function(Pointer<Void> seq, Uint32 index, Pointer<SHVar> item);
typedef SHSeqPop = SHVar Function(Pointer<Void> seq);
typedef SHSeqResize = Void Function(Pointer<Void> seq, Uint32 size);
typedef SHSeqFastDelete = Void Function(Pointer<Void> seq, Uint32 index);
typedef SHSeqSlowDelete = Void Function(Pointer<Void> seq, Uint32 index);

// Additional typedefs for SHCore function types
typedef SHStringGrow = Void Function(Pointer<Void> str, Uint32 newCap);
typedef SHStringFree = Void Function(Pointer<Void> str);

typedef ShardsComposeShards =
    Pointer<Void> Function(Pointer<Void> shards, Pointer<Void> data);
typedef ShardsRunShardsHashed =
    Uint8 Function(
      Pointer<Void> shards,
      Pointer<SHContext> context,
      Pointer<SHVar> input,
      Pointer<SHVar> output,
      Pointer<SHVar> outHash,
    );

typedef ShardsLogLevel = Void Function(Int32 level, SHStringWithLen msg);
typedef ShardsLogLevelDart = void Function(int level, SHStringWithLen msg);

typedef SHCreateShard = Pointer<Void> Function(Pointer<Utf8> name);
typedef SHReleaseShard = Void Function(Pointer<Void> shard);
typedef SHValidateSetParam =
    Int32 Function(Pointer<Void> shard, Int32 index, Pointer<SHVar> param);

typedef SHCreateWire = Pointer<Void> Function(Pointer<Utf8> name);
typedef SHSetWireLooped = Void Function(Pointer<Void> wire, Int32 looped);
typedef SHSetWireUnsafe = Void Function(Pointer<Void> wire, Int32 unsafe);
typedef SHSetWirePure = Void Function(Pointer<Void> wire, Int32 pure);
typedef SHSetWireStackSize =
    Void Function(Pointer<Void> wire, Uint64 stackSize);
typedef SHSetWirePriority = Void Function(Pointer<Void> wire, Int32 priority);
typedef SHSetWireTraits =
    Void Function(Pointer<Void> wire, Pointer<Void> traits);
typedef SHAddShard = Void Function(Pointer<Void> wire, Pointer<Void> shard);
typedef SHRemShard = Void Function(Pointer<Void> wire, Pointer<Void> shard);
typedef SHReferenceWire = Pointer<Void> Function(Pointer<Void> wire);
typedef SHDestroyWire = Void Function(Pointer<Void> wire);
typedef SHIsWireRunning = Int32 Function(Pointer<Void> wire);
typedef SHStopWire = SHVar Function(Pointer<Void> wire);
typedef SHComposeWire =
    Pointer<Void> Function(Pointer<Void> wire, Pointer<Void> data);
typedef SHRunWire =
    Pointer<Void> Function(
      Pointer<Void> wire,
      Pointer<SHContext> context,
      Pointer<SHVar> input,
    );
typedef SHGetWireInfo = Pointer<Void> Function(Pointer<Void> wire);
typedef SHGetGlobalWire = Pointer<Void> Function(Pointer<Utf8> name);
typedef SHSetGlobalWire = Void Function(Pointer<Utf8> name, Pointer<Void> wire);
typedef SHUnsetGlobalWire = Void Function(Pointer<Utf8> name);

// Mesh operation typedefs
typedef SHCreateMesh = Pointer<Void> Function();
typedef SHDestroyMesh = Void Function(Pointer<Void> mesh);
typedef SHCreateMeshVar = SHVar Function();
typedef SHSetMeshLabel = Void Function(Pointer<Void> mesh, Pointer<Utf8> label);
typedef SHCompose = Int32 Function(Pointer<Void> mesh, Pointer<Void> wire);
typedef SHSchedule =
    Void Function(Pointer<Void> mesh, Pointer<Void> wire, Int32 compose);
typedef SHUnSchedule = Void Function(Pointer<Void> mesh, Pointer<Void> wire);
typedef SHTick = Int32 Function(Pointer<Void> mesh);
typedef SHTerminate = Void Function(Pointer<Void> mesh);
typedef SHSleep = Void Function(Double seconds);
typedef SHGetStepCount = Uint64 Function(Pointer<SHContext> context);

// Async and registration typedefs
typedef SHRunAsyncActivate =
    SHVar Function(
      Pointer<SHContext> context,
      Pointer<Void> userData,
      Pointer<NativeFunction<SHAsyncActivateProc>> call,
      Pointer<NativeFunction<SHAsyncCancelProc>> cancel_call,
    );

typedef SHGetShards = Pointer<Void> Function();
typedef SHRegisterShard =
    Void Function(
      Pointer<Utf8> fullName,
      Pointer<NativeFunction<Void Function()>> constructor,
    );
typedef SHRegisterObjectType =
    Void Function(Int32 vendorId, Int32 typeId, Pointer<Void> info);
typedef SHRegisterEnumType =
    Void Function(Int32 vendorId, Int32 typeId, Pointer<Void> info);

// Variable management typedefs
typedef SHReferenceVariable =
    Pointer<SHVar> Function(Pointer<SHContext> context, Pointer<Utf8> name);
typedef SHReferenceWireVariable =
    Pointer<SHVar> Function(Pointer<Void> wire, Pointer<Utf8> name);
typedef SHReleaseVariable = Void Function(Pointer<SHVar> variable);
typedef SHSetExternalVariable =
    Void Function(Pointer<Void> wire, Pointer<Utf8> name, Pointer<Void> pVar);
typedef SHRemoveExternalVariable =
    Void Function(Pointer<Void> wire, Pointer<Utf8> name);
typedef SHAllocExternalVariable =
    Pointer<SHVar> Function(
      Pointer<Void> wire,
      Pointer<Utf8> name,
      Pointer<Void> type,
    );
typedef SHFreeExternalVariable =
    Void Function(Pointer<Void> wire, Pointer<Utf8> name);

// Async callback typedefs
typedef SHAsyncActivateProc =
    SHVar Function(Pointer<SHContext> context, Pointer<Void> userData);
typedef SHAsyncCancelProc =
    Void Function(Pointer<SHContext> context, Pointer<Void> userData);

// Mesh variable typedefs
typedef SHGetMeshVariable =
    Pointer<SHVar> Function(Pointer<Void> mesh, Pointer<Utf8> name);
typedef SHSetMeshVariableType =
    Void Function(Pointer<Void> mesh, Pointer<Utf8> name, Pointer<Void> type);

// Wire state typedefs
typedef SHSuspend = Uint8 Function(Pointer<SHContext> context, Double seconds);
typedef SHGetState = Uint8 Function(Pointer<SHContext> context);
typedef SHAbortWire =
    Void Function(Pointer<SHContext> context, Pointer<Utf8> errorText);

// Variable operations typedefs
typedef SHCloneVar = Void Function(Pointer<SHVar> dst, Pointer<SHVar> src);
typedef SHDestroyVar = Void Function(Pointer<SHVar> varPtr);
typedef SHHashVar = SHVar Function(Pointer<SHVar> varPtr);

// String cache typedefs
typedef SHReadCachedString = Pointer<Utf8> Function(Uint32 id);
typedef SHWriteCachedString =
    Pointer<Utf8> Function(Uint32 id, Pointer<Utf8> str);
typedef SHDecompressStrings = Void Function();

// Comparison typedefs
typedef SHIsEqualVar = Int32 Function(Pointer<SHVar> v1, Pointer<SHVar> v2);
typedef SHCompareVar = Int32 Function(Pointer<SHVar> v1, Pointer<SHVar> v2);
typedef SHIsEqualType = Int32 Function(Pointer<Void> t1, Pointer<Void> t2);
typedef SHDeriveTypeInfo =
    Pointer<Void> Function(Pointer<SHVar> v, Pointer<Void> data, Int32 mutable);
typedef SHFreeDerivedTypeInfo = Void Function(Pointer<Void> t);

// Type info typedefs
typedef SHFindEnumInfo = Pointer<Void> Function(Int32 vendorId, Int32 typeId);
typedef SHFindEnumId = Int64 Function(Pointer<Utf8> name);
typedef SHFindObjectInfo = Pointer<Void> Function(Int32 vendorId, Int32 typeId);
typedef SHFindObjectTypeId = Int64 Function(Pointer<Utf8> name);
typedef SHType2Name = Pointer<Utf8> Function(Int32 type);

// Language operation typedefs
typedef SHReadProc =
    Pointer<Void> Function(
      Pointer<Utf8> name,
      Pointer<Utf8> code,
      Pointer<Utf8> basePath,
      Pointer<Pointer<Utf8>> includeDirs,
      Uint32 numIncludeDirs,
    );
typedef SHLoadAstProc =
    Pointer<Void> Function(Pointer<Uint8> bytes, Uint32 size);
typedef SHFreeError = Void Function(Pointer<Void> error);
typedef SHCreateEvalEnv = Pointer<Void> Function(Pointer<Utf8> namespace);
typedef SHFreeEvalEnv = Void Function(Pointer<Void> env);
typedef SHEvalProc =
    Pointer<Void> Function(Pointer<Void> env, Pointer<SHVar> ast);
typedef SHTransformEnv =
    Pointer<Void> Function(Pointer<Void> env, Pointer<Utf8> name);
typedef SHFreeWire = Void Function(Pointer<Void> wire);

base class SHCore extends Struct {
  // Memory management
  external Pointer<NativeFunction<SHAlloc>> alloc;
  external Pointer<NativeFunction<SHFree>> free;

  // String operations
  external Pointer<NativeFunction<SHStringGrow>> stringGrow;
  external Pointer<NativeFunction<SHStringFree>> stringFree;

  // Table operations
  external Pointer<NativeFunction<SHTableNew>> tableNew;

  // Utility to use shards within shards
  external Pointer<NativeFunction<ShardsComposeShards>> composeShards;
  external Pointer<NativeFunction<ShardsRunShards>> runShards;
  external Pointer<NativeFunction<ShardsRunShards>> runShards2;
  external Pointer<NativeFunction<ShardsRunShardsHashed>> runShardsHashed;
  external Pointer<NativeFunction<ShardsRunShardsHashed>> runShardsHashed2;

  // Logging
  external Pointer<NativeFunction<ShardsLog>> log;
  external Pointer<NativeFunction<ShardsLogLevel>> logLevel;

  // Wire creation and management
  external Pointer<NativeFunction<SHCreateShard>> createShard;
  external Pointer<NativeFunction<SHReleaseShard>> releaseShard;
  external Pointer<NativeFunction<SHValidateSetParam>> validateSetParam;

  external Pointer<NativeFunction<SHCreateWire>> createWire;
  external Pointer<NativeFunction<SHSetWireLooped>> setWireLooped;
  external Pointer<NativeFunction<SHSetWireUnsafe>> setWireUnsafe;
  external Pointer<NativeFunction<SHSetWirePure>> setWirePure;
  external Pointer<NativeFunction<SHSetWireStackSize>> setWireStackSize;
  external Pointer<NativeFunction<SHSetWirePriority>> setWirePriority;
  external Pointer<NativeFunction<SHSetWireTraits>> setWireTraits;
  external Pointer<NativeFunction<SHAddShard>> addShard;
  external Pointer<NativeFunction<SHRemShard>> removeShard;
  external Pointer<NativeFunction<SHReferenceWire>> referenceWire;
  external Pointer<NativeFunction<SHDestroyWire>> destroyWire;
  external Pointer<NativeFunction<SHIsWireRunning>> isWireRunning;
  external Pointer<NativeFunction<SHStopWire>> stopWire;
  external Pointer<NativeFunction<SHComposeWire>> composeWire;
  external Pointer<NativeFunction<SHRunWire>> runWire;
  external Pointer<NativeFunction<SHGetWireInfo>> getWireInfo;
  external Pointer<NativeFunction<SHGetGlobalWire>> getGlobalWire;
  external Pointer<NativeFunction<SHSetGlobalWire>> setGlobalWire;
  external Pointer<NativeFunction<SHUnsetGlobalWire>> unsetGlobalWire;

  // Wire scheduling
  external Pointer<NativeFunction<SHCreateMesh>> createMesh;
  external Pointer<NativeFunction<SHDestroyMesh>> destroyMesh;
  external Pointer<NativeFunction<SHCreateMeshVar>> createMeshVar;
  external Pointer<NativeFunction<SHSetMeshLabel>> setMeshLabel;
  external Pointer<NativeFunction<SHCompose>> compose;
  external Pointer<NativeFunction<SHSchedule>> schedule;
  external Pointer<NativeFunction<SHUnSchedule>> unschedule;
  external Pointer<NativeFunction<SHTick>> tick;
  external Pointer<NativeFunction<SHTick>> isEmpty;
  external Pointer<NativeFunction<SHTerminate>> terminate;
  external Pointer<NativeFunction<SHSleep>> sleep;
  external Pointer<NativeFunction<SHGetStepCount>> getStepCount;

  // Environment utilities
  external Pointer<NativeFunction<ShardsSetRootPath>> setRootPath;
  external Pointer<NativeFunction<SHGetRootPath>> getRootPath;

  // Async execution
  external Pointer<NativeFunction<SHRunAsyncActivate>> asyncActivate;

  // Shards discovery
  external Pointer<NativeFunction<SHGetShards>> getShards;

  // Registration
  external Pointer<NativeFunction<SHRegisterShard>> registerShard;
  external Pointer<NativeFunction<SHRegisterObjectType>> registerObjectType;
  external Pointer<NativeFunction<SHRegisterEnumType>> registerEnumType;

  // Variable management within shards
  external Pointer<NativeFunction<SHReferenceVariable>> referenceVariable;
  external Pointer<NativeFunction<SHReferenceWireVariable>>
  referenceWireVariable;
  external Pointer<NativeFunction<SHReleaseVariable>> releaseVariable;

  // External variables for wires
  external Pointer<NativeFunction<SHSetExternalVariable>> setExternalVariable;
  external Pointer<NativeFunction<SHRemoveExternalVariable>>
  removeExternalVariable;
  external Pointer<NativeFunction<SHAllocExternalVariable>>
  allocExternalVariable;
  external Pointer<NativeFunction<SHFreeExternalVariable>> freeExternalVariable;

  external Pointer<NativeFunction<SHGetMeshVariable>> getMeshVariable;
  external Pointer<NativeFunction<SHSetMeshVariableType>> setMeshVariableType;

  // Coroutine control
  external Pointer<NativeFunction<SHSuspend>> suspend;
  external Pointer<NativeFunction<SHGetState>> getState;
  external Pointer<NativeFunction<SHAbortWire>> abortWire;

  // SHVar utilities
  external Pointer<NativeFunction<SHCloneVar>> cloneVar;
  external Pointer<NativeFunction<SHDestroyVar>> destroyVar;
  external Pointer<NativeFunction<SHHashVar>> hashVar;

  // Compressed strings
  external Pointer<NativeFunction<SHReadCachedString>> readCachedString;
  external Pointer<NativeFunction<SHWriteCachedString>> writeCachedString;
  external Pointer<NativeFunction<SHDecompressStrings>> decompressStrings;

  // Image handling
  external Pointer<NativeFunction<SHImageIncRef>> imageIncRef;
  external Pointer<NativeFunction<SHImageDecRef>> imageDecRef;
  external Pointer<NativeFunction<SHImageNew>> imageNew;
  external Pointer<NativeFunction<SHImageClone>> imageClone;
  external Pointer<NativeFunction<SHImageDeriveDataLength>>
  imageDeriveDataLength;

  // Comparison utilities
  external Pointer<NativeFunction<SHIsEqualVar>> isEqualVar;
  external Pointer<NativeFunction<SHCompareVar>> compareVar;
  external Pointer<NativeFunction<SHIsEqualType>> isEqualType;
  external Pointer<NativeFunction<SHDeriveTypeInfo>> deriveTypeInfo;
  external Pointer<NativeFunction<SHFreeDerivedTypeInfo>> freeDerivedTypeInfo;

  // Type info utilities
  external Pointer<NativeFunction<SHFindEnumInfo>> findEnumInfo;
  external Pointer<NativeFunction<SHFindEnumId>> findEnumId;
  external Pointer<NativeFunction<SHFindObjectInfo>> findObjectInfo;
  external Pointer<NativeFunction<SHFindObjectTypeId>> findObjectTypeId;
  external Pointer<NativeFunction<SHType2Name>> type2Name;

  // Language parsing and evaluation
  external Pointer<NativeFunction<SHReadProc>> read;
  external Pointer<NativeFunction<SHLoadAstProc>> loadAst;
  external Pointer<NativeFunction<SHFreeError>> freeError;
  external Pointer<NativeFunction<SHCreateEvalEnv>> createEvalEnv;
  external Pointer<NativeFunction<SHFreeEvalEnv>> freeEvalEnv;
  external Pointer<NativeFunction<SHEvalProc>> eval;
  external Pointer<NativeFunction<SHTransformEnv>> transformEnv;
  external Pointer<NativeFunction<SHFreeWire>> freeWire;

  // Array operations
  external Pointer<NativeFunction<SHSeqFree>> seqFree;
  external Pointer<NativeFunction<SHSeqPush>> seqPush;
  external Pointer<NativeFunction<SHSeqInsert>> seqInsert;
  external Pointer<NativeFunction<SHSeqPop>> seqPop;
  external Pointer<NativeFunction<SHSeqResize>> seqResize;
  external Pointer<NativeFunction<SHSeqFastDelete>> seqFastDelete;
  external Pointer<NativeFunction<SHSeqSlowDelete>> seqSlowDelete;

  // Types array operations
  external Pointer<NativeFunction<SHSeqFree>> typesFree;
  external Pointer<NativeFunction<SHSeqPush>> typesPush;
  external Pointer<NativeFunction<SHSeqInsert>> typesInsert;
  external Pointer<NativeFunction<SHSeqPop>> typesPop;
  external Pointer<NativeFunction<SHSeqResize>> typesResize;
  external Pointer<NativeFunction<SHSeqFastDelete>> typesFastDelete;
  external Pointer<NativeFunction<SHSeqSlowDelete>> typesSlowDelete;

  // Parameters array operations
  external Pointer<NativeFunction<SHSeqFree>> paramsFree;
  external Pointer<NativeFunction<SHSeqPush>> paramsPush;
  external Pointer<NativeFunction<SHSeqInsert>> paramsInsert;
  external Pointer<NativeFunction<SHSeqPop>> paramsPop;
  external Pointer<NativeFunction<SHSeqResize>> paramsResize;
  external Pointer<NativeFunction<SHSeqFastDelete>> paramsFastDelete;
  external Pointer<NativeFunction<SHSeqSlowDelete>> paramsSlowDelete;

  // Shards array operations
  external Pointer<NativeFunction<SHSeqFree>> shardsFree;
  external Pointer<NativeFunction<SHSeqPush>> shardsPush;
  external Pointer<NativeFunction<SHSeqInsert>> shardsInsert;
  external Pointer<NativeFunction<SHSeqPop>> shardsPop;
  external Pointer<NativeFunction<SHSeqResize>> shardsResize;
  external Pointer<NativeFunction<SHSeqFastDelete>> shardsFastDelete;
  external Pointer<NativeFunction<SHSeqSlowDelete>> shardsSlowDelete;

  // Exposed types array operations
  external Pointer<NativeFunction<SHSeqFree>> expTypesFree;
  external Pointer<NativeFunction<SHSeqPush>> expTypesPush;
  external Pointer<NativeFunction<SHSeqInsert>> expTypesInsert;
  external Pointer<NativeFunction<SHSeqPop>> expTypesPop;
  external Pointer<NativeFunction<SHSeqResize>> expTypesResize;
  external Pointer<NativeFunction<SHSeqFastDelete>> expTypesFastDelete;
  external Pointer<NativeFunction<SHSeqSlowDelete>> expTypesSlowDelete;

  // Enums array operations
  external Pointer<NativeFunction<SHSeqFree>> enumsFree;
  external Pointer<NativeFunction<SHSeqPush>> enumsPush;
  external Pointer<NativeFunction<SHSeqInsert>> enumsInsert;
  external Pointer<NativeFunction<SHSeqPop>> enumsPop;
  external Pointer<NativeFunction<SHSeqResize>> enumsResize;
  external Pointer<NativeFunction<SHSeqFastDelete>> enumsFastDelete;
  external Pointer<NativeFunction<SHSeqSlowDelete>> enumsSlowDelete;

  // Strings array operations
  external Pointer<NativeFunction<SHSeqFree>> stringsFree;
  external Pointer<NativeFunction<SHSeqPush>> stringsPush;
  external Pointer<NativeFunction<SHSeqInsert>> stringsInsert;
  external Pointer<NativeFunction<SHSeqPop>> stringsPop;
  external Pointer<NativeFunction<SHSeqResize>> stringsResize;
  external Pointer<NativeFunction<SHSeqFastDelete>> stringsFastDelete;
  external Pointer<NativeFunction<SHSeqSlowDelete>> stringsSlowDelete;

  // Trait variables array operations
  external Pointer<NativeFunction<SHSeqFree>> traitVariablesFree;
  external Pointer<NativeFunction<SHSeqPush>> traitVariablesPush;
  external Pointer<NativeFunction<SHSeqInsert>> traitVariablesInsert;
  external Pointer<NativeFunction<SHSeqPop>> traitVariablesPop;
  external Pointer<NativeFunction<SHSeqResize>> traitVariablesResize;
  external Pointer<NativeFunction<SHSeqFastDelete>> traitVariablesFastDelete;
  external Pointer<NativeFunction<SHSeqSlowDelete>> traitVariablesSlowDelete;

  // Traits array operations
  external Pointer<NativeFunction<SHSeqFree>> traitsFree;
  external Pointer<NativeFunction<SHSeqPush>> traitsPush;
  external Pointer<NativeFunction<SHSeqInsert>> traitsInsert;
  external Pointer<NativeFunction<SHSeqPop>> traitsPop;
  external Pointer<NativeFunction<SHSeqResize>> traitsResize;
  external Pointer<NativeFunction<SHSeqFastDelete>> traitsFastDelete;
  external Pointer<NativeFunction<SHSeqSlowDelete>> traitsSlowDelete;
}

typedef ShardsCloneVar = Void Function(Pointer<SHVar> dst, Pointer<SHVar> src);
typedef ShardsCloneVarDart =
    void Function(Pointer<SHVar> dst, Pointer<SHVar> src);

typedef ShardsDestroyVar = Void Function(Pointer<SHVar> varPtr);
typedef ShardsDestroyVarDart = void Function(Pointer<SHVar> varPtr);

typedef ShardsLog = Void Function(SHStringWithLen message);
typedef ShardsLogDart = void Function(SHStringWithLen message);

typedef ShardsSetRootPath = Void Function(SHStringWithLen path);
typedef ShardsSetRootPathDart = void Function(SHStringWithLen path);

typedef ShardsRunShards =
    Uint8 Function(
      Pointer<Shards> shards,
      Pointer<SHContext> context,
      Pointer<SHVar> input,
      Pointer<SHVar> output,
    );
typedef ShardsRunShardsDart =
    int Function(
      Pointer<Shards> shards,
      Pointer<SHContext> context,
      Pointer<SHVar> input,
      Pointer<SHVar> output,
    );

// Helper class for Dart interface
class ShardsInterface {
  final Pointer<SHCore> _core;

  ShardsInterface() : _core = shardsInterface(0x20200102);

  void cloneVar(Pointer<SHVar> dst, Pointer<SHVar> src) {
    final func = _core.ref.cloneVar.asFunction<ShardsCloneVarDart>();
    func(dst, src);
  }

  void destroyVar(Pointer<SHVar> varPtr) {
    final func = _core.ref.destroyVar.asFunction<ShardsDestroyVarDart>();
    func(varPtr);
  }

  void log(String message) {
    final func = _core.ref.log.asFunction<ShardsLogDart>();
    using((Arena arena) {
      final nativeStr = message.toNativeUtf8(allocator: arena);
      final strWithLen = arena<SHStringWithLen>();
      strWithLen.ref.string = nativeStr.cast();
      strWithLen.ref.len = nativeStr.length;
      func(strWithLen.ref);
    });
  }

  void logLevel(int level, String message) {
    final func = _core.ref.logLevel.asFunction<ShardsLogLevelDart>();
    using((Arena arena) {
      final nativeStr = message.toNativeUtf8(allocator: arena);
      final strWithLen = arena<SHStringWithLen>();
      strWithLen.ref.string = nativeStr.cast();
      strWithLen.ref.len = nativeStr.length;
      func(level, strWithLen.ref);
    });
  }

  void setRootPath(String path) {
    final func = _core.ref.setRootPath.asFunction<ShardsSetRootPathDart>();
    using((Arena arena) {
      final nativeStr = path.toNativeUtf8(allocator: arena);
      final strWithLen = arena<SHStringWithLen>();
      strWithLen.ref.string = nativeStr.cast();
      strWithLen.ref.len = path.length;
      func(strWithLen.ref);
    });
  }

  int runShards(
    Pointer<Shards> shards,
    Pointer<SHContext> context,
    Pointer<SHVar> input,
    Pointer<SHVar> output,
  ) {
    final func = _core.ref.runShards.asFunction<ShardsRunShardsDart>();
    return func(shards, context, input, output);
  }

  // Add wrappers for other core functions
}

// Context and Shards structures (opaque)
base class SHContext extends Opaque {}

base class Shards extends Opaque {}

// Helper extension for working with SHVar
extension SHVarExtensions on Pointer<SHVar> {
  String get stringValue {
    final payload = ref.payload;
    return payload.stringValue.cast<Utf8>().toDartString();
  }

  void setInt(int value) {
    ref.payload.intValue = value;
    ref.valueType = SHType.Int;
  }

  int get intValue {
    if (ref.valueType != SHType.Int) {
      throw Exception('Attempting to read non-int value as int');
    }
    return ref.payload.intValue;
  }

  double get floatValue => ref.payload.floatValue;

  void setString(String value) {
    final nativeString = value.toNativeUtf8();
    ref.payload.stringValue = nativeString.cast();
    ref.payload.stringLen = value.length;
  }
}

// Define DynamicLibrary for shardsLib
final DynamicLibrary shardsLib = DynamicLibrary.process();

// Example usage
Future<void> test_shards() async {
  // Get the application support directory
  final appSupportDir = await getApplicationDocumentsDirectory();
  final shardsDir = Directory('${appSupportDir.path}/Shards');

  // Create the directory if it doesn't exist
  if (!await shardsDir.exists()) {
    await shardsDir.create(recursive: true);
  }

  // Change to the Shards directory
  Directory.current = shardsDir.path;

  final shards = ShardsInterface();
  print('ShardsInterface created: ${shards._core}');

  shards.log("Hello, World!");

  final varPtr = calloc<SHVar>();
  Pointer<SHVar>? cloned;
  try {
    varPtr.ref.valueType = SHType.Int;
    varPtr.ref.payload.intValue = 42;
    print('Var value: ${varPtr.ref.payload.intValue}');

    cloned = calloc<SHVar>();
    shards.cloneVar(cloned, varPtr);
    print('Cloned value: ${cloned.ref.payload.intValue}');
  } finally {
    shards.destroyVar(varPtr);
    if (cloned != null) {
      shards.destroyVar(cloned);
      calloc.free(cloned);
    }
    calloc.free(varPtr);
  }
}
