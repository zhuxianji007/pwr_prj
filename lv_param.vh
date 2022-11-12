parameter FSM_REQ_ADC_NUM   = 4,
parameter FSM_REQ_ADC_CNT_W = (FSM_REQ_ADC_NUM==1) ? 1 : $clog2(FSM_REQ_ADC_NUM),
