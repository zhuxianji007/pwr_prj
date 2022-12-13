parameter ADC_DW                = 10                                                        ,

parameter REG_DW                = 8                                                         ,
parameter REG_AW                = 7                                                         ,
parameter REG_CRC_W             = 8                                                         ,
parameter REQ_ADC_ADDR          = 7'h1f                                                     ,

parameter OWT_FSM_ST_NUM        = 9                                                         ,
parameter OWT_EXT_CYC_NUM       = 12                                                        ,
parameter OWT_CRC_BIT_NUM       = 8                                                         ,
parameter OWT_CMD_BIT_NUM       = 8                                                         ,
parameter OWT_DATA_BIT_NUM      = 8                                                         ,
parameter OWT_ADCD_BIT_NUM      = 20                                                        ,
parameter OWT_SYNC_BIT_NUM      = 12                                                        ,
parameter OWT_TAIL_BIT_NUM      = 4                                                         ,
parameter OWT_ABORT_BIT_NUM     = 4                                                         ,
parameter OWT_FSM_ST_W          = $clog2(OWT_FSM_ST_NUM)                                    ,
parameter CNT_OWT_EXT_CYC_W     = $clog2(OWT_EXT_CYC_NUM+1)                                 ,
parameter CNT_OWT_MAX_W         = $clog2(OWT_ADCD_BIT_NUM)                                  ,
parameter OWT_IDLE_ST           = OWT_FSM_ST_W'(0)                                          ,
parameter OWT_SYNC_HEAD_ST      = OWT_FSM_ST_W'(1)                                          ,
parameter OWT_SYNC_TAIL_ST      = OWT_FSM_ST_W'(2)                                          , 
parameter OWT_CMD_ST            = OWT_FSM_ST_W'(3)                                          ,
parameter OWT_NML_DATA_ST       = OWT_FSM_ST_W'(4)                                          ,//normal data
parameter OWT_ADC_DATA_ST       = OWT_FSM_ST_W'(5)                                          ,
parameter OWT_CRC_ST            = OWT_FSM_ST_W'(6)                                          ,
parameter OWT_END_TAIL_ST       = OWT_FSM_ST_W'(7)                                          ,
parameter OWT_ABORT_ST          = OWT_FSM_ST_W'(8)                                          ,

parameter CLK_M                 =  48                                                       ,
parameter  WDG_250US_CYC_NUM    =  250*CLK_M                                                , //one core clk cycle is (1000/48)ns, 250us has (250x1000)ns/(1000/48)ns = 250x48 cycle.
parameter  WDG_500US_CYC_NUM    =  500*CLK_M                                                ,
parameter WDG_1000US_CYC_NUM    = 1000*CLK_M                                                ,
parameter WDG_2000US_CYC_NUM    = 2000*CLK_M                                                ,
parameter WDG_SCANREG_TH[3: 0]  = {WDG_2000US_CYC_NUM, WDG_1000US_CYC_NUM, WDG_500US_CYC_NUM, WDG_250US_CYC_NUM}, //TH = threshold
parameter WDG_REFRESH_TH[3: 0]  = {WDG_2000US_CYC_NUM, WDG_1000US_CYC_NUM, WDG_500US_CYC_NUM, WDG_250US_CYC_NUM},
parameter WDG_TIMEOUT_TH[3: 0]  = {WDG_2000US_CYC_NUM, WDG_1000US_CYC_NUM, WDG_500US_CYC_NUM, WDG_250US_CYC_NUM},
parameter WDG_INTB_TH[3: 0]     = {WDG_2000US_CYC_NUM, WDG_1000US_CYC_NUM, WDG_500US_CYC_NUM, WDG_250US_CYC_NUM},
parameter WDG_CNT_W             = $clog2(WDG_2000US_CYC_NUM) ,

parameter PWM_INTB_EXT_CYC_NUM  = 8,
parameter HV_DV_ID              = 4'(0),
parameter LV_DV_ID              = 4'(0),

parameter OWT_COM_ERR_SET_NUM[3: 0]  = {32, 16, 8, 4}                   ,
parameter OWT_COM_COR_SUB_NUM[3: 0]  = {8 , 4 , 2, 1}                   ,
parameter OWT_COM_MAX_ERR_NUM        = 512                              ,
parameter OWT_COM_ERR_CNT_W          = $clog2(OWT_COM_MAX_ERR_NUM+1)    ,
parameter INIT_OWT_COM_ERR_NUM       = OWT_COM_ERR_CNT_W'(32)           ,





