parameter FSM_ST_NUM            = 11                                                    ,
parameter FSM_ST_W              = FSM_ST_NUM ? 1 : $clog2(FSM_ST_NUM)                   ,
parameter REG_DW                = 8                                                     ,
parameter REG_AW                = 7                                                     ,
parameter REG_CRC_W             = 8                                                     ,
parameter FSM_ST_NUM            = 11                                                    ,
parameter FSM_ST_W              = FSM_ST_NUM ? 1 : $clog2(FSM_ST_NUM)                   ,
parameter FSM_REQ_ADC_NUM       = 4                                                     ,
parameter FSM_REQ_ADC_CNT_W     = (FSM_REQ_ADC_NUM==1) ? 1 : $clog2(FSM_REQ_ADC_NUM)    ,
parameter REQ_ADC_ADDR          = 7'h1f                                                 ,

parameter OWT_FSM_ST_NUM        = 9                                                     ,
parameter OWT_EXT_CYC_NUM       = 12                                                    ,
parameter OWT_CRC_BIT_NUM       = 8                                                     ,
parameter OWT_CMD_BIT_NUM       = 8                                                     ,
parameter OWT_DATA_BIT_NUM      = 8                                                     ,
parameter OWT_ADCD_BIT_NUM      = 20                                                    ,
parameter OWT_SYNC_BIT_NUM      = 12                                                    ,
parameter OWT_TAIL_BIT_NUM      = 4                                                     ,
parameter OWT_ABORT_BIT_NUM     = 4                                                     ,
parameter OWT_FSM_ST_W          = $clog2(OWT_FSM_ST_NUM)                                ,
parameter CNT_OWT_EXT_CYC_W     = $clog2(EXT_CYC_NUM+1)                                 ,
parameter CNT_OWT_MAX_W         = $clog2(ADC_DBIT_NUM)                                  ,
parameter OWT_IDLE_ST           = OWT_FSM_ST_W'(0)                                      ,
parameter OWT_SYNC_HEAD_ST      = OWT_FSM_ST_W'(1)                                      ,
parameter OWT_SYNC_TAIL_ST      = OWT_FSM_ST_W'(2)                                      , 
parameter OWT_CMD_ST            = OWT_FSM_ST_W'(3)                                      ,
parameter OWT_NML_DATA_ST       = OWT_FSM_ST_W'(4)                                      ,//normal data
parameter OWT_ADC_DATA_ST       = OWT_FSM_ST_W'(5)                                      ,
parameter OWT_CRC_ST            = OWT_FSM_ST_W'(6)                                      ,
parameter OWT_END_TAIL_ST       = OWT_FSM_ST_W'(7)                                      ,
parameter OWT_ABORT_ST          = OWT_FSM_ST_W'(8)                                      , 
