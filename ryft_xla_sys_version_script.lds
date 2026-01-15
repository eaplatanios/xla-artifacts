# The symbols listed in the "global" section of this file--and only those--
#    are discoverable by programs or frameworks that `dlopen()` libtpu.
# The linker will expose those symbols and no others to frameworks.
VERS_1.0 {
  global:
    extern "C" {
      GetPjrtApi;
      XLA_FFI_GetApi;
      PJRT_Distributed_Runtime_Service_New;
      PJRT_Distributed_Runtime_Service_Shutdown;
      PJRT_Distributed_Runtime_Service_Destroy;
      PJRT_Distributed_Runtime_Client_New;
      PJRT_Distributed_Runtime_Client_Connect;
      PJRT_Distributed_Runtime_Client_Blocking_Key_Value_Get;
      PJRT_Distributed_Runtime_Client_Key_Value_Try_Get;
      PJRT_Distributed_Runtime_Client_Key_Value_Set;
      PJRT_Distributed_Runtime_Client_Shutdown;
      PJRT_Distributed_Runtime_Client_Destroy;
      mlir*;
      chlo*;
      stablehlo*;
      sdy*;
    };

  local:
    *;
};
