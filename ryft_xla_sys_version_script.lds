VERS_1.0 {
  global:
    GetPjrtApi;
    XLA_FFI_GetApi;
    PJRT_Distributed_Runtime_Service_*;
    PJRT_Distributed_Runtime_Client_*;
    mlir*;
    chlo*;
    stablehlo*;
    sdy*;

  local:
    *;
};
