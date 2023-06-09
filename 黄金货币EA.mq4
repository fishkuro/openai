//+------------------------------------------------------------------+
//|                                                      Warthog.mq4 |
//|                                          Copyright 2022, Another |
//|                                                  17905184@qq.com |
//|//////////////////////////////////////////////////////////////////|
//|////////////////////很牛叉很生猛的算法策略////////////////////////|
//|//////////////////////////////////////////////////////////////////|

 #property copyright "Warthog黄金疣猪"
 #property link "https://www.kurodo.cn"
 #property description "一款很牛叉很生猛的算法EA，希望该EA能像非洲野猪一样生猛"
 #property version "1.00"
 #property strict

extern string EAComment = ""; //注释
extern string Ownership = "挂欧美黄金1小时周期"; //EA Comment
extern string Telegram_Group = "1000美金建议0.01开始挂，3000建议0.05开始"; //Telegram Group
extern double TakeProfit = 20; //止盈
extern double OrderSteps = 15; //加仓间距(15)
extern bool ExitOpposite = false; //通过反向信号退出
extern double MaxSpread = 13; //最大点差
extern int Slippage = 2; //滑点
extern int MagicNumber = 1; //订单识别码
extern double NumberOrders = 7; //最大单量
extern bool ShowInfo = true; //显示信息
extern string TrailingStopLoss = "---移动止损---"; //移动止损
extern bool UseTrailingStop = false; //是否运用移动止损
extern double TrailingStart = 15; //移动止损开始点数
extern double TrailingStep = 1; //移动止损步进值
extern double TrailingStop = 10; //移动止损跟随点数
extern bool UseTrailingSAR = false; //是否用抛物线指标运用移动止损
extern double stepSAR = 1; //抛物线步进值
extern int levelSAR = 8; //抛物线参数
extern string MM_Settings = "---资金管理设置---"; //资金管理设置
extern double Lot = 0.01; //手数
extern bool UseRisk = false; //自动风险手数比例
extern double RiskPercent = 0.1; //风险比例值
extern bool Martingale = true; //是否运用马丁格尔策略
extern double Multiplier = 1.5; //马丁格尔倍率
extern string Time_Filter = "---交易时间过滤---"; //交易时间过滤
extern bool Use_Time_Filter = false; //是否使用时间过滤
extern string Time_Start = "06:00"; //开始时间
extern string Time_End = "16:00"; //结束时间
extern string MACD = "---Controller---"; //MACD设置
extern int MACD_Fast_EMA = 30; //快线设置
extern int MACD_Slow_EMA = 40; //慢线设置
extern int MACD_SMA = 6; //柱线设置
extern ENUM_APPLIED_PRICE MACD_Price = 0; //MACD运用价格
extern int BarShift = 0; //K线偏移值
extern string MoneyMagagement = "------风险和盈利控制设置 ----"; //风险和盈利控制设置
extern double MarginProtection = 90; //最大平仓亏损百分比
extern string DiscreetSetting = "-------分批出场设置-------"; //分批出场设置
extern bool UseDiscreetLots = false; //是否运用分批出场
extern double DiscreetLots = 0.03; //分批出场手数
extern double DiscreetMultiplier = 4; //分批出场次数
extern string NewsTrade_Setting = "-------新闻事件设置-------"; //新闻事件设置
extern bool UseNewsFilter = true; //是否运用新闻过滤
extern bool TurnOff_EA = false; //是否关闭ea运行
extern bool UseDiscreetMode = true; //是否运用分批参数
extern int OffBeforeNews = 30; //在新闻事件前多久关闭ea
extern int OnAfterNews = 25; //在新闻事件后多久开启ea
extern string newsType = "--------新闻类型设置--------------"; //新闻类型设置
extern bool IncludeLowImpact = false; //低风险事件
extern bool IncludeMediumImpact = false; //中度风险事件
extern bool IncludeHighImpact = true; //高风险事件
extern bool IncludeHolidays = false; //是否包括假日过滤
extern bool IncludeMeetings = false; //是否包括会议事件
extern bool IncludeSpeeches = false; //是否包括讲话事件
extern string CurrencyFilterList = "ALL"; //货币对过滤器，默认为所有
extern bool ShowNews_OnthisPair = true; //在本品种上显示新闻
extern bool NFP_only = false; //是否仅仅是非农过滤
extern string _Other_ = "+++++++++++ 信息参数设定 +++++++++++"; //信息参数设定
extern bool DisplayInfo_On = true; //是否显示信息
extern int Textsize = 9; //字体大小
extern int TextCorner = 1; //字体角落位置
extern string FontName = "Tahoma"; //字体设置
extern color TextColor = 16443110; //字体颜色
extern int TextXAnchor = 20; //文字X轴位置
extern int TextYAnchor = 20; //文字Y轴位置
extern int TextYFirst = 0; //文字Y轴第一个字位置

int BarShiftCount = 0;
int ModeLotstep = 0;     //总_40_in
double ModeDigits = 0.0001;   //总_35_do

datetime LocalTime = 0; //总_5_da
datetime OffBeforeTime = 0; //总_6_da
datetime OnAfterTime = 0; //总_7_da
int LocalTimeAdd = 0; //总_24_in
int LocalTimeSec = 0; //总_26_in

double UserLots = 0.0; //总_30_do
string NewsTitle = ""; //总_22_st
int NewsTimeCurrent = 0; //总_4_in
string OrderTypeStr = ""; //总_14_st
//double    总_28_do = 0.0;//iSARFastLine
//double    总_29_do = 0.0;//iSARSlowLine

//TP 1500-2500
//SL 总得超过多少全清掉保仓
//DiscreetLots 分批参数别乱开，会改变基础手数

bool      总_8_bo = false;
double    总_13_do = 0.0;
double    总_15_do = 0.0;
double    总_16_do = 0.0;
double    总_17_do = 0.0;   //计算收益 - 功能上没用
double    总_18_do = 0.0;   //计算收益 - 功能上没用
double    总_32_do = 0.0;
double    总_38_do = 0.0;

// 指标数据结构体
struct Indicator {
    // 趋势转向 //预留
    bool IsOverBuy;
    bool IsOverSell;

    // 买多信号
    bool IsBuySignal;
    // 卖空信号
    bool IsSellSignal;

    //抛物线信号
    double iSARFastLine;
    double iSARSlowLine;
};

// 订单统计
struct Counter {
    int BuyTotal; // 多单计数
    int SellTotal; // 空单计数
    int AllTotal; // 全部订单计数
    double PointTotal; // 获利点数
    //double ProfitTotal; // 获利金额
    double BuyProfit; // 多单获利金额
    double SellProfit; // 空单获利金额
    double AllProfit; //全部获利金额
    double LastSellLots; // 最后一笔空单手数量
    double LastBuyLots; // 最后一笔多单手数量
    
    double OverWinLine; //及时止盈价格线

    double OtherOrderValue; //其他持仓成本
    double OtherOrderLots; //其他持仓数量

    int LastOrderType; //最后一笔订单类型
    int LastOrderTicket; //最后一笔订单号
    double LastOrderLots;  //最后一笔持仓数量
    double LastOrderOpenPrice; //最后一笔开仓价格
    double LastOrderTakeProfit; //最后一笔止盈价格
    double LastOrderStopLoss; //最后一笔止损价格
    int BarsDelta; // 最近一笔订单与当前时间的间隔
};

// EA运行的周期
int RunPeriod = PERIOD_H1;

#import "stdlib.ex4"
string ErrorDescription(int error);
#import

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
void OnInit() {
    BarShiftCount = BarShift;

    if (MarketInfo(Symbol(), 24) >= 1.0) {
        ModeLotstep = 0;
    }
    if (MarketInfo(Symbol(), 24) >= 0.1) {
        ModeLotstep = 1;
    }
    if (MarketInfo(Symbol(), 24) >= 0.01) {
        ModeLotstep = 2;
    }

    if (MarketInfo(_Symbol, 12) == 1.0) {
        ModeDigits = 1.0;
    }
    if (MarketInfo(_Symbol, 12) == 0.0) {
        ModeDigits = 1.0;
    }
    if ((MarketInfo(_Symbol, 12) == 4.0 || MarketInfo(_Symbol, 12) == 5.0)) {
        ModeDigits = 0.0001;
    }
    if ((MarketInfo(_Symbol, 12) == 2.0 || MarketInfo(_Symbol, 12) == 3.0) && MarketInfo(_Symbol, 9) > 1000.0) {
        ModeDigits = 1.0;
    }
    if ((MarketInfo(_Symbol, 12) == 2.0 || MarketInfo(_Symbol, 12) == 3.0) && MarketInfo(_Symbol, 9) < 1000.0) {
        ModeDigits = 0.01;
    }
    if ((StringFind(_Symbol, "XAU", 0) > -1 || StringFind(_Symbol, "xau", 0) > -1 || StringFind(_Symbol, "GOLD", 0) > -1)) {
        ModeDigits = 0.1;
    }

    if (ShowNews_OnthisPair) {
        CurrencyFilterList = Symbol();
        return;
    }
    CurrencyFilterList = "ALL";
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    EventKillTimer();
    Comment("");

    for (int i = GlobalVariablesTotal() - 1; i >= 0; i = i - 1) {
        if (StringFind(GlobalVariableName(i), "GV", 0) != -1) {
            GlobalVariableDel(GlobalVariableName(i));
        }
    }

    for (int i = ObjectsTotal(-1) - 1; i >= 0; i = i - 1) {
        if (StringFind(ObjectName(i), WindowExpertName(), 0) != -1) {
            ObjectDelete(ObjectName(i));
        }

        if (StringFind(ObjectName(i), "zNews", 0) != -1) {
            ObjectDelete(ObjectName(i));
        }
    }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
    HideTestIndicators(true);

    bool newsLimit = false;
    bool runState = true;
    bool 临_bo_7 = false;
    bool 临_bo_11 = false;
    string 子_6_st = "";
    int       子_5_in;
    int       子_7_in;
    int       子_8_in;
    int       子_9_in;
    int       子_10_in;

    总_8_bo = false ;
    if (UseNewsFilter) {
        OnTimer();
        if (LocalTime == 0) {
            LocalTime = TimeLocal() + LocalTimeAdd;
        }

        if (LocalTime != 0) {
            OffBeforeTime = LocalTime - OffBeforeNews * 60;
            OnAfterTime = LocalTime + OnAfterNews * 60;
            if (TimeLocal() >= LocalTime - OffBeforeNews * 60 && TimeLocal() < LocalTime + OnAfterNews * 60) {
                newsLimit = true;
            }
        }
        if (TimeLocal() > OnAfterTime) {
            LocalTime = 0;
        }
    }

    if (TurnOff_EA) {
        //      if ( 子_1_bo )
        //      {
        //         子_2_bo = false;
        //      }
        //
        //      if ( !(子_2_bo) )
        //      {
        //         for (子_4_in = OrdersTotal() - 1 ; 子_4_in >= 0 ; 子_4_in = 子_4_in - 1)
        //         {
        //            if ( !(OrderSelect(子_4_in,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
        //            OrderOpenTime();
        //         }
        //      }
    }

    if (newsLimit) {
        if ( UseDiscreetMode )
        {
           总_8_bo = true;
        }
        //分批出场，默认开
        if (!(TurnOff_EA) && 总_8_bo) {
            runState = true;
        }
        if (TurnOff_EA) {
            runState = false;
        }
    }

    // 指标计算
    Indicator ind = CalcInd();

    // 统计仓位
    Counter counter = CalcTotal();

    分批出场(counter);

    移动止盈止损(ind, counter);

    if (UseTrailingSAR) {
        抛物线移动止损(ind, counter);
    } else {
        移动止损();
    }

    if ((AccountFreeMarginCheck(Symbol(), 0, UserLots) <= 0.0 || AccountFreeMarginCheck(Symbol(), 1, UserLots) <= 0.0 || GetLastError() == 134)) {
        Print("NOT ENOUGH MONEY TO TRADE OPEN");
        return;
    }

    //运行状态
    if (runState) {

        //临_in_2 = 0;
        //for (临_in_3 = 0 ; 临_in_3 < OrdersTotal() ; 临_in_3=临_in_3 + 1)
        //{
        //  if ( !(OrderSelect(临_in_3,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
        //  临_in_2=临_in_2 + 1;
        //}
        //子_6_st = DoubleToString(临_in_2,0) ;
        子_6_st = IntegerToString(counter.AllTotal);
        //   临_in_4 = -1;
        //   临_in_5 = 0;
        //   for (临_in_6 = OrdersTotal() - 1 ; 临_in_6 >= 0 ; 临_in_6=临_in_6 - 1)
        //   {
        //     if ( !(OrderSelect(临_in_6,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
        //
        //     if ( 临_in_4 <  0 )
        //     {
        //       临_in_5=临_in_5 + 1;
        //     }
        //     if ( OrderType() == 临_in_4 && 临_in_4 >= 0 )
        //     {
        //       临_in_5=临_in_5 + 1;
        //     }
        //     if ( OrderType() <= 1 && 临_in_4 == 8 )
        //     {
        //       临_in_5=临_in_5 + 1;
        //     }
        //     if ( OrderType() >  1 && 临_in_4 == 9 )
        //     {
        //       临_in_5=临_in_5 + 1;
        //     }
        //     if ( ( OrderType() == 0 || OrderType() == 2 || OrderType() == 4 ) && 临_in_4 == 6 )
        //     {
        //       临_in_5=临_in_5 + 1;
        //     }
        //     if ( ( OrderType() != 1 && OrderType() != 3 && OrderType() != 5 ) || 临_in_4 != 7 )   continue;
        //     临_in_5=临_in_5 + 1;
        //
        //   }
        //if ( 临_in_5 <  1 && 总_47_bo )
        if (counter.AllTotal < 1 && ind.IsBuySignal) {
            if (!(Use_Time_Filter)) {
                临_bo_7 = true;
            } else {
                if (Use_Time_Filter && StringToTime(Time_Start) < StringToTime(Time_End) && TimeCurrent() >= StringToTime(Time_Start) && TimeCurrent() < StringToTime(Time_End)) {
                    临_bo_7 = true;
                } else {
                    if (Use_Time_Filter && StringToTime(Time_Start) > StringToTime(Time_End) && ((TimeCurrent() >= StringToTime(Time_Start) && TimeCurrent() < StringToTime("23:59")) || (TimeCurrent() < StringToTime(Time_End) && TimeCurrent() >= StringToTime("00:01")))) {
                        临_bo_7 = true;
                    } else {
                        临_bo_7 = false;
                    }
                }
            }
            if (临_bo_7) {
                if (TakeProfit == 0.0) {
                    总_32_do = 0.0;
                } else {
                    总_32_do = TakeProfit * ModeDigits + Ask;
                }
                子_7_in = OrderSend(Symbol(), OP_BUY, UserLots, Ask, 1, 0.0, 总_32_do, 子_6_st + " " + EAComment, MagicNumber, 0, Green);
                子_5_in = GetLastError();
                if (子_5_in != 0) {
                    Print("Error on Order open = ", ErrorDescription(子_5_in));
                }
            }
        }
        //   临_in_8 = -1;
        //   临_in_9 = 0;
        //   for (临_in_10 = OrdersTotal() - 1 ; 临_in_10 >= 0 ; 临_in_10=临_in_10 - 1)
        //   {
        //     if ( !(OrderSelect(临_in_10,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
        //
        //     if ( 临_in_8 <  0 )
        //     {
        //       临_in_9=临_in_9 + 1;
        //     }
        //     if ( OrderType() == 临_in_8 && 临_in_8 >= 0 )
        //     {
        //       临_in_9=临_in_9 + 1;
        //     }
        //     if ( OrderType() <= 1 && 临_in_8 == 8 )
        //     {
        //       临_in_9=临_in_9 + 1;
        //     }
        //     if ( OrderType() >  1 && 临_in_8 == 9 )
        //     {
        //       临_in_9=临_in_9 + 1;
        //     }
        //     if ( ( OrderType() == 0 || OrderType() == 2 || OrderType() == 4 ) && 临_in_8 == 6 )
        //     {
        //       临_in_9=临_in_9 + 1;
        //     }
        //     if ( ( OrderType() != 1 && OrderType() != 3 && OrderType() != 5 ) || 临_in_8 != 7 )   continue;
        //     临_in_9=临_in_9 + 1;
        //
        //   }
        //if ( 临_in_9 <  1 && 总_48_bo )
        if (counter.AllTotal < 1 && ind.IsSellSignal) {
            if (!(Use_Time_Filter)) {
                临_bo_11 = true;
            } else {
                if (Use_Time_Filter && StringToTime(Time_Start) < StringToTime(Time_End) && TimeCurrent() >= StringToTime(Time_Start) && TimeCurrent() < StringToTime(Time_End)) {
                    临_bo_11 = true;
                } else {
                    if (Use_Time_Filter && StringToTime(Time_Start) > StringToTime(Time_End) && ((TimeCurrent() >= StringToTime(Time_Start) && TimeCurrent() < StringToTime("23:59")) || (TimeCurrent() < StringToTime(Time_End) && TimeCurrent() >= StringToTime("00:01")))) {
                        临_bo_11 = true;
                    } else {
                        临_bo_11 = false;
                    }
                }
            }
            if (临_bo_11) {
                if (TakeProfit == 0.0) {
                    总_32_do = 0.0;
                } else {
                    总_32_do = Bid - TakeProfit * ModeDigits;
                }
                子_8_in = OrderSend(Symbol(), OP_SELL, UserLots, Bid, 1, 0.0, 总_32_do, 子_6_st + " " + EAComment, MagicNumber, 0, Red);
                子_5_in = GetLastError();
                if (子_5_in != 0) {
                    Print("Error on Order open = ", ErrorDescription(子_5_in));
                }
            }
        }
        //   临_in_12 = 0;
        //   临_in_13 = 0;
        //   for (临_in_14 = OrdersTotal() - 1 ; 临_in_14 >= 0 ; 临_in_14=临_in_14 - 1)
        //   {
        //     if ( !(OrderSelect(临_in_14,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
        //
        //     if ( 临_in_12 <  0 )
        //     {
        //       临_in_13=临_in_13 + 1;
        //     }
        //     if ( OrderType() == 临_in_12 && 临_in_12 >= 0 )
        //     {
        //       临_in_13=临_in_13 + 1;
        //     }
        //     if ( OrderType() <= 1 && 临_in_12 == 8 )
        //     {
        //       临_in_13=临_in_13 + 1;
        //     }
        //     if ( OrderType() >  1 && 临_in_12 == 9 )
        //     {
        //       临_in_13=临_in_13 + 1;
        //     }
        //     if ( ( OrderType() == 0 || OrderType() == 2 || OrderType() == 4 ) && 临_in_12 == 6 )
        //     {
        //       临_in_13=临_in_13 + 1;
        //     }
        //     if ( ( OrderType() != 1 && OrderType() != 3 && OrderType() != 5 ) || 临_in_12 != 7 )   continue;
        //     临_in_13=临_in_13 + 1;
        //
        //   }
        //   if ( 临_in_13 >  0 )
        if (counter.BuyTotal > 0) //多方加仓
        {
            //     临_in_15 = 0;
            //     临_in_16 = 0;
            //     for (临_in_17 = OrdersTotal() - 1 ; 临_in_17 >= 0 ; 临_in_17=临_in_17 - 1)
            //     {
            //       if ( !(OrderSelect(临_in_17,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
            //
            //       if ( 临_in_15 <  0 )
            //       {
            //         临_in_16=临_in_16 + 1;
            //       }
            //       if ( OrderType() == 临_in_15 && 临_in_15 >= 0 )
            //       {
            //         临_in_16=临_in_16 + 1;
            //       }
            //       if ( OrderType() <= 1 && 临_in_15 == 8 )
            //       {
            //         临_in_16=临_in_16 + 1;
            //       }
            //       if ( OrderType() >  1 && 临_in_15 == 9 )
            //       {
            //         临_in_16=临_in_16 + 1;
            //       }
            //       if ( ( OrderType() == 0 || OrderType() == 2 || OrderType() == 4 ) && 临_in_15 == 6 )
            //       {
            //         临_in_16=临_in_16 + 1;
            //       }
            //       if ( ( OrderType() != 1 && OrderType() != 3 && OrderType() != 5 ) || 临_in_15 != 7 )   continue;
            //       临_in_16=临_in_16 + 1;
            //
            //     }
            //     if ( NumberOrders>临_in_16 )
            if (NumberOrders > counter.BuyTotal) {
//                临_st_18 = "price";
//                临_do_19 = 0.0;
//                临_do_20 = 0.0;
//                临_in_21 = 0;
//                临_in_22 = 0;
//                for (临_in_23 = OrdersTotal() - 1; 临_in_23 >= 0; 临_in_23 = 临_in_23 - 1) {
//                    if (!(OrderSelect(临_in_23, SELECT_BY_POS, MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
//                        continue;
//                    临_in_22 = OrderTicket();
//                    if (临_in_22 <= 临_in_21)
//                        continue;
//                    临_in_21 = 临_in_22;
//                    临_do_19 = OrderOpenPrice();
//                    临_do_20 = OrderLots();
//
//                }
//                if (临_st_18 == "price") {
//                    临_do_24 = 临_do_19;
//                }
                //else
                //{
                //  if ( 临_st_18 == "lot" )
                //  {
                //    临_do_24 = 临_do_20;
                //  }
                //  else
                //  {
                //    临_do_24 = 0.0;
                //  }
                //}
                //if (临_do_24 - OrderSteps * 总_35_do >= Ask) {
                //if(counter.LastOrderOpenPrice - OrderSteps * ModeDigits >= Ask) {
                if(Ask < counter.LastOrderOpenPrice - OrderSteps * ModeDigits) {
                    子_9_in = OrderSend(Symbol(), OP_BUY, UserLots, Ask, 1, 0.0, 0.0, 子_6_st + " " + EAComment, MagicNumber, 0, Green);
                    子_5_in = GetLastError();
                    if (子_5_in != 0) {
                        Print("Error on Order open = ", ErrorDescription(子_5_in));
                    }
                    //加仓有BUG,计算太快了，连续开仓了
                    Sleep(1000);
                }
            }
        }
        //   临_in_25 = 1;
        //   临_in_26 = 0;
        //   for (临_in_27 = OrdersTotal() - 1 ; 临_in_27 >= 0 ; 临_in_27=临_in_27 - 1)
        //   {
        //     if ( !(OrderSelect(临_in_27,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
        //
        //     if ( 临_in_25 <  0 )
        //     {
        //       临_in_26=临_in_26 + 1;
        //     }
        //     if ( OrderType() == 临_in_25 && 临_in_25 >= 0 )
        //     {
        //       临_in_26=临_in_26 + 1;
        //     }
        //     if ( OrderType() <= 1 && 临_in_25 == 8 )
        //     {
        //       临_in_26=临_in_26 + 1;
        //     }
        //     if ( OrderType() >  1 && 临_in_25 == 9 )
        //     {
        //       临_in_26=临_in_26 + 1;
        //     }
        //     if ( ( OrderType() == 0 || OrderType() == 2 || OrderType() == 4 ) && 临_in_25 == 6 )
        //     {
        //       临_in_26=临_in_26 + 1;
        //     }
        //     if ( ( OrderType() != 1 && OrderType() != 3 && OrderType() != 5 ) || 临_in_25 != 7 )   continue;
        //     临_in_26=临_in_26 + 1;
        //
        //   }
        //   if ( 临_in_26 >  0 )
        if (counter.SellTotal > 0) {
            //     临_in_28 = 1;
            //     临_in_29 = 0;
            //     for (临_in_30 = OrdersTotal() - 1 ; 临_in_30 >= 0 ; 临_in_30=临_in_30 - 1)
            //     {
            //       if ( !(OrderSelect(临_in_30,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
            //
            //       if ( 临_in_28 <  0 )
            //       {
            //         临_in_29=临_in_29 + 1;
            //       }
            //       if ( OrderType() == 临_in_28 && 临_in_28 >= 0 )
            //       {
            //         临_in_29=临_in_29 + 1;
            //       }
            //       if ( OrderType() <= 1 && 临_in_28 == 8 )
            //       {
            //         临_in_29=临_in_29 + 1;
            //       }
            //       if ( OrderType() >  1 && 临_in_28 == 9 )
            //       {
            //         临_in_29=临_in_29 + 1;
            //       }
            //       if ( ( OrderType() == 0 || OrderType() == 2 || OrderType() == 4 ) && 临_in_28 == 6 )
            //       {
            //         临_in_29=临_in_29 + 1;
            //       }
            //       if ( ( OrderType() != 1 && OrderType() != 3 && OrderType() != 5 ) || 临_in_28 != 7 )   continue;
            //       临_in_29=临_in_29 + 1;
            //
            //     }
            //     if ( NumberOrders>临_in_29 )
            if (NumberOrders > counter.SellTotal) {
//                临_st_31 = "price";
//                临_do_32 = 0.0;
//                临_do_33 = 0.0;
//                临_in_34 = 0;
//                临_in_35 = 0;
//                for (临_in_36 = OrdersTotal() - 1; 临_in_36 >= 0; 临_in_36 = 临_in_36 - 1) {
//                    if (!(OrderSelect(临_in_36, SELECT_BY_POS, MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
//                        continue;
//                    临_in_35 = OrderTicket();
//                    if (临_in_35 <= 临_in_34)
//                        continue;
//                    临_in_34 = 临_in_35;
//                    临_do_32 = OrderOpenPrice();
//                    临_do_33 = OrderLots();
//
//                }
//                if (临_st_31 == "price") {
//                    临_do_37 = 临_do_32;
//                }
                //else
                //{
                //  if ( 临_st_31 == "lot" )
                //  {
                //    临_do_37 = 临_do_33;
                //  }
                //  else
                //  {
                //    临_do_37 = 0.0;
                //  }
                //}
                //if (OrderSteps * 总_35_do + 临_do_37 <= Bid) {
                //if (OrderSteps * ModeDigits + counter.LastOrderOpenPrice <= Bid) {
                if(Bid > counter.LastOrderOpenPrice + OrderSteps * ModeDigits) {
//                    临_st_38 = "price";
//                    临_do_39 = 0.0;
//                    临_do_40 = 0.0;
//                    临_in_41 = 0;
//                    临_in_42 = 0;
//                    for (临_in_43 = OrdersTotal() - 1; 临_in_43 >= 0; 临_in_43 = 临_in_43 - 1) {
//                        if (!(OrderSelect(临_in_43, SELECT_BY_POS, MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
//                            continue;
//                        临_in_42 = OrderTicket();
//                        if (临_in_42 <= 临_in_41)
//                            continue;
//                        临_in_41 = 临_in_42;
//                        临_do_39 = OrderOpenPrice();
//                        临_do_40 = OrderLots();
//
//                    }
//                    if (临_st_38 == "price") {
//                        临_do_44 = 临_do_39;
//                    }
                    //else
                    //{
                    //  if ( 临_st_38 == "lot" )
                    //  {
                    //    临_do_44 = 临_do_40;
                    //  }
                    //  else
                    //  {
                    //    临_do_44 = 0.0;
                    //  }
                    //}
                    //if (临_do_44 > 0.0) {
                    if(counter.LastOrderOpenPrice > 0.0) {
                        子_10_in = OrderSend(Symbol(), OP_SELL, UserLots, Bid, 1, 0.0, 0.0, 子_6_st + " " + EAComment, MagicNumber, 0, Red);
                        子_5_in = GetLastError();
                        if (子_5_in != 0) {
                            Print("Error on Order open = ", ErrorDescription(子_5_in));
                        }
                        //加仓有BUG,计算太快了，连续开仓了
                        Sleep(1000);
                    }
                }
            }
        }

    }
}

void OnTimer() {
    LocalTimeSec = TimeGMT() - (TimeCurrent() + (int(NormalizeDouble((TimeGMT() - TimeCurrent()) / 3600.0, 0))) * 3600);
    int newsPower = 新闻权重加载();
    LocalTimeAdd = newsPower * 60 - TimeSeconds(TimeGMT());
    显示字幕信息();
}

//////////////////////////////////////////////////////////////////////
/////////////////// 自定义函数区 /////////////////////////////////////
//////////////////////////////////////////////////////////////////////

//+------------------------------------------------------------------+
//| 指标计算                                                         |
//+------------------------------------------------------------------+
Indicator CalcInd() {
    Indicator ind = {};

    // 趋势转向
    //ind.IsOverBuy =
    //ind.IsOverSell =

    // 买卖信号 //OsMA 1 多 2 空 //猜的
    ind.IsBuySignal = iCustom(_Symbol, 0, "OsMA_Divergence", 1, BarShiftCount + 2) != INT_MAX && iMACD(NULL, 0, MACD_Fast_EMA, MACD_Slow_EMA, MACD_SMA, MACD_Price, 0, BarShiftCount) > 0.0;
    ind.IsSellSignal = iCustom(_Symbol, 0, "OsMA_Divergence", 2, BarShiftCount + 2) != INT_MAX && iMACD(NULL, 0, MACD_Fast_EMA, MACD_Slow_EMA, MACD_SMA, MACD_Price, 0, BarShiftCount) < 0.0;

    // 抛物线信号
    ind.iSARFastLine = iSAR(Symbol(), 0, stepSAR, 0.2, 0);
    ind.iSARSlowLine = iSAR(Symbol(), 0, stepSAR, 0.2, 1);

    return ind;
}

//+------------------------------------------------------------------+
//| 统计订单数量                                                     |
//+------------------------------------------------------------------+
Counter CalcTotal() {
    Counter counter = {};
    int ticket = 0;
    for (int i = 0; i < OrdersTotal(); i++) {
        //如果 仓单编号不符合，或者 选中仓单失败，跳过        
        if ( !(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;

        //统计利润
        //counter.ProfitTotal += OrderProfit();

        // 下单时间间隔的K线数量：秒转分转周期
        int diff = (int)((TimeCurrent() - OrderOpenTime()) / 60 / RunPeriod);
        // 最新的订单id最大
        if (OrderTicket() > ticket)
            counter.BarsDelta = diff;

        //多单
        if (OrderType() == OP_BUY) {
            // 计数
            counter.BuyTotal++;
            // 计利润点数
            counter.PointTotal += MathPow(10, _Digits) * (Bid - OrderOpenPrice()) / 10;
            counter.BuyProfit += OrderProfit();
            if (OrderLots() > counter.LastBuyLots) {
                counter.LastBuyLots = OrderLots();
                
                counter.LastOrderLots = counter.LastBuyLots;
                counter.LastOrderType = OrderType();
                counter.LastOrderTicket = OrderTicket();
                counter.LastOrderOpenPrice = OrderOpenPrice();
                counter.LastOrderTakeProfit = OrderTakeProfit();
                counter.LastOrderStopLoss = OrderStopLoss();
            }

        }
        //空单
        else if (OrderType() == OP_SELL) {
            // 计数
            counter.SellTotal++;
            // 计利润点数
            counter.PointTotal += MathPow(10, _Digits) * (OrderOpenPrice() - Ask) / 10;
            counter.SellProfit += OrderProfit();
            if (OrderLots() > counter.LastSellLots) {
                counter.LastSellLots = OrderLots();
                
                counter.LastOrderLots = counter.LastSellLots;
                counter.LastOrderType = OrderType();
                counter.LastOrderTicket = OrderTicket();
                counter.LastOrderOpenPrice = OrderOpenPrice();
                counter.LastOrderTakeProfit = OrderTakeProfit();
                counter.LastOrderStopLoss = OrderStopLoss();
            }
        } else if (OrderType() > 1) {
            counter.OtherOrderValue += OrderOpenPrice() * OrderLots();
            counter.OtherOrderLots += OrderLots();
        }

        //合计
        counter.AllTotal = counter.BuyTotal + counter.SellTotal;
        counter.AllProfit = counter.BuyProfit + counter.SellProfit;
    }
    return counter;
}

//+------------------------------------------------------------------+
//| 移动止盈止损                                                     |
//+------------------------------------------------------------------+
void 移动止盈止损(const Indicator & ind, const Counter & counter) {
    //double 子_1_do;
    //double 子_2_do;
    //int 子_3_in;
    //bool 子_4_bo;
    int 子_5_in;
    bool 子_6_bo;
    double 子_7_do;
    int 子_8_in;
    bool 子_9_bo;
    bool 子_10_bo;
    bool 子_11_bo;
    //----- -----
    //int 临_in_1;
    //int 临_in_2;
    //int 临_in_3;
    //int 临_in_4;
    //int 临_in_5;
    //int 临_in_6;
    //int 临_in_7;
    //int 临_in_8;
    //int 临_in_9;

    if (UseTrailingSAR) {
        抛物线移动止损(ind, counter);
    }
    // 子_1_do = 0.0 ;   //所有持仓价值
    // 子_2_do = 0.0 ;   //所有持仓手数
    总_13_do = 0.0;
    //其他挂单的价值 OrderType() > 1
    // for (子_3_in = OrdersTotal() - 1 ; 子_3_in >= 0 ; 子_3_in = 子_3_in - 1)
    // {
    //   子_4_bo = OrderSelect(子_3_in,SELECT_BY_POS,MODE_TRADES) ;
    //   if ( OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber || OrderType() > 1 )   continue;
    //   子_1_do = OrderOpenPrice() * OrderLots() + 子_1_do ;
    //   子_2_do = 子_2_do + OrderLots() ;
    //
    // }
    // 临_in_1 = 8;
    // 临_in_2 = 0;
    // for (临_in_3 = OrdersTotal() - 1 ; 临_in_3 >= 0 ; 临_in_3=临_in_3 - 1)
    // {
    //   if ( !(OrderSelect(临_in_3,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
    //
    //   if ( 临_in_1 <  0 )
    //   {
    //     临_in_2=临_in_2 + 1;
    //   }
    //   if ( OrderType() == 临_in_1 && 临_in_1 >= 0 )
    //   {
    //     临_in_2=临_in_2 + 1;
    //   }
    //   if ( OrderType() <= 1 && 临_in_1 == 8 )
    //   {
    //     临_in_2=临_in_2 + 1;
    //   }
    //   if ( OrderType() >  1 && 临_in_1 == 9 )
    //   {
    //     临_in_2=临_in_2 + 1;
    //   }
    //   if ( ( OrderType() == 0 || OrderType() == 2 || OrderType() == 4 ) && 临_in_1 == 6 )
    //   {
    //     临_in_2=临_in_2 + 1;
    //   }
    //   if ( ( OrderType() != 1 && OrderType() != 3 && OrderType() != 5 ) || 临_in_1 != 7 )   continue;
    //   临_in_2=临_in_2 + 1;
    //
    // }
    // if ( 临_in_2 >  1 && 子_1_do!=0.0 )
    if (counter.AllProfit > 1 && counter.OtherOrderValue != 0.0) {
        //总_38_do = NormalizeDouble(子_1_do / 子_2_do,Digits) ;
        总_38_do = NormalizeDouble(counter.OtherOrderValue / counter.OtherOrderLots, Digits);
    }
    // 临_in_4 = 8;
    // 临_in_5 = 0;
    // for (临_in_6 = OrdersTotal() - 1 ; 临_in_6 >= 0 ; 临_in_6=临_in_6 - 1)
    // {
    //   if ( !(OrderSelect(临_in_6,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
    //
    //   if ( 临_in_4 <  0 )
    //   {
    //     临_in_5=临_in_5 + 1;
    //   }
    //   if ( OrderType() == 临_in_4 && 临_in_4 >= 0 )
    //   {
    //     临_in_5=临_in_5 + 1;
    //   }
    //   if ( OrderType() <= 1 && 临_in_4 == 8 )
    //   {
    //     临_in_5=临_in_5 + 1;
    //   }
    //   if ( OrderType() >  1 && 临_in_4 == 9 )
    //   {
    //     临_in_5=临_in_5 + 1;
    //   }
    //   if ( ( OrderType() == 0 || OrderType() == 2 || OrderType() == 4 ) && 临_in_4 == 6 )
    //   {
    //     临_in_5=临_in_5 + 1;
    //   }
    //   if ( ( OrderType() != 1 && OrderType() != 3 && OrderType() != 5 ) || 临_in_4 != 7 )   continue;
    //   临_in_5=临_in_5 + 1;
    //
    // }
    // if ( 临_in_5 >  1 )
    if (counter.AllTotal > 1) {
        for (子_5_in = OrdersTotal() - 1; 子_5_in >= 0; 子_5_in = 子_5_in - 1) {
            if ( !(OrderSelect(子_5_in,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;

            if (OrderType() == 0) {
                总_13_do = TakeProfit * ModeDigits + 总_38_do;
            }
            if (OrderType() != 1)
                continue;
            总_13_do = 总_38_do - TakeProfit * ModeDigits;

        }
    }
    子_7_do = MarketInfo(Symbol(), 14) * ModeDigits;
    // 临_in_7 = 8;
    // 临_in_8 = 0;
    // for (临_in_9 = OrdersTotal() - 1 ; 临_in_9 >= 0 ; 临_in_9=临_in_9 - 1)
    // {
    //   if ( !(OrderSelect(临_in_9,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
    //
    //   if ( 临_in_7 <  0 )
    //   {
    //     临_in_8=临_in_8 + 1;
    //   }
    //   if ( OrderType() == 临_in_7 && 临_in_7 >= 0 )
    //   {
    //     临_in_8=临_in_8 + 1;
    //   }
    //   if ( OrderType() <= 1 && 临_in_7 == 8 )
    //   {
    //     临_in_8=临_in_8 + 1;
    //   }
    //   if ( OrderType() >  1 && 临_in_7 == 9 )
    //   {
    //     临_in_8=临_in_8 + 1;
    //   }
    //   if ( ( OrderType() == 0 || OrderType() == 2 || OrderType() == 4 ) && 临_in_7 == 6 )
    //   {
    //     临_in_8=临_in_8 + 1;
    //   }
    //   if ( ( OrderType() != 1 && OrderType() != 3 && OrderType() != 5 ) || 临_in_7 != 7 )   continue;
    //   临_in_8=临_in_8 + 1;
    //
    // }
    // if ( 临_in_8 <= 1 )   return;
    if (counter.AllTotal <= 1)
        return;
    for (子_8_in = OrdersTotal() - 1; 子_8_in >= 0; 子_8_in = 子_8_in - 1) {
        //子_9_bo = OrderSelect(子_8_in, SELECT_BY_POS, MODE_TRADES);
        //if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber || OrderType() > 1 || !(NormalizeDouble(总_13_do, Digits) != OrderTakeProfit()))
        //    continue;
        if ( !(OrderSelect(子_8_in,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;

        if (!(UseTrailingSAR)) {
            子_10_bo = OrderModify(OrderTicket(), NormalizeDouble(总_38_do, Digits), NormalizeDouble(OrderStopLoss(), Digits), NormalizeDouble(总_13_do, Digits), 0, Yellow);
            continue;
        }
        if (!(总_16_do != 0.0) || !(OrderStopLoss() != 总_16_do))
            continue;

        if ((!(Bid - 总_16_do > 子_7_do) && !(总_16_do - Ask > 子_7_do)))
            continue;
        子_11_bo = OrderModify(OrderTicket(), NormalizeDouble(总_38_do, Digits), NormalizeDouble(总_16_do, Digits), 0.0, 0, Yellow);

    }
}

//有用分批修改开仓规则，0.03 4 前 4层是按0.03开仓 后面才是手数
//+------------------------------------------------------------------+
//| 分批出场函数                                                     |
//+------------------------------------------------------------------+
void 分批出场(const Counter & counter) {
    //UserLots = Lot;
    //double 子_1_do = 0.0;
    //double 子_2_do = MarketInfo(Symbol(), 24);

    double 子_1_do;
    double 子_2_do;
    double 子_3_do;
    //----- -----
    //int 临_in_1;
    //int 临_in_2;
    //int 临_in_3;
    //int 临_in_4;
    //string 临_st_5;
    //double 临_do_6;
    //double 临_do_7;
    //int 临_in_8;
    //int 临_in_9;
    //int 临_in_10;
    //double 临_do_11;
    //string 临_st_12;
    //double 临_do_13;
    //double 临_do_14;
    //int 临_in_15;
    //int 临_in_16;
    //int 临_in_17;
    //double 临_do_18;
    //int 临_in_19;
    //int 临_in_20;
    //int 临_in_21;
    //int 临_in_22;
    //int 临_in_23;
    //string 临_st_24;
    //double 临_do_25;
    //double 临_do_26;
    //int 临_in_27;
    //int 临_in_28;
    //int 临_in_29;
    //double 临_do_30;
    //int 临_in_31;
    //int 临_in_32;
    //int 临_in_33;
    //int 临_in_34;
    //int 临_in_35;

    //总_30_do = Lot ;
    UserLots = Lot;
    子_1_do = 0.0;
    子_2_do = MarketInfo(Symbol(), 24);
    if (UseRisk) {
        UserLots = MathFloor(AccountFreeMargin() * RiskPercent / 100.0 / MarketInfo(Symbol(), 32) / MarketInfo(Symbol(), 24)) * MarketInfo(Symbol(), 24);
    }
    if ((UseDiscreetLots || 总_8_bo)) {
        //   临_in_1 = 0;
        //   for (临_in_2 = 0 ; 临_in_2 < OrdersTotal() ; 临_in_2=临_in_2 + 1)
        //   {
        //     if ( !(OrderSelect(临_in_2,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
        //     临_in_1=临_in_1 + 1;
        //
        //   }
        //   if ( 临_in_1<DiscreetMultiplier )
        if (counter.AllTotal < DiscreetMultiplier) {
            UserLots = DiscreetLots;
        } else {
            //     临_in_3 = 0;
            //     for (临_in_4 = 0 ; 临_in_4 < OrdersTotal() ; 临_in_4=临_in_4 + 1)
            //     {
            //       if ( !(OrderSelect(临_in_4,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
            //       临_in_3=临_in_3 + 1;
            //
            //     }
            //     for (子_3_do = 临_in_3 ; 子_3_do>0.0 ; 子_3_do = 子_3_do - DiscreetMultiplier)
            for (子_3_do = counter.AllTotal; 子_3_do > 0.0; 子_3_do = 子_3_do - DiscreetMultiplier) {}
            if (子_3_do == 0.0) {
//                临_st_5 = "lot";
//                临_do_6 = 0.0;
//                临_do_7 = 0.0;
//                临_in_8 = 0;
//                临_in_9 = 0;
//                for (临_in_10 = OrdersTotal() - 1; 临_in_10 >= 0; 临_in_10 = 临_in_10 - 1) {
//                    if (!(OrderSelect(临_in_10, SELECT_BY_POS, MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
//                        continue;
//                    临_in_9 = OrderTicket();
//                    if (临_in_9 <= 临_in_8)
//                        continue;
//                    临_in_8 = 临_in_9;
//                    临_do_6 = OrderOpenPrice();
//                    临_do_7 = OrderLots();
//
//                }
//
//                if (临_st_5 == "lot") {
//                    临_do_11 = 临_do_7;
//                } else {
//                    临_do_11 = 0.0;
//                }

                //if ( 临_st_5 == "price" )
                //{
                //  临_do_11 = 临_do_6;
                //}
                //else
                //{
                //  if ( 临_st_5 == "lot" )
                //  {
                //    临_do_11 = 临_do_7;
                //  }
                //  else
                //  {
                //    临_do_11 = 0.0;
                //  }
                //}
                //UserLots = MathRound(临_do_11 * Multiplier / 子_2_do) * 子_2_do;
                UserLots = MathRound(counter.LastOrderLots * Multiplier / 子_2_do) * 子_2_do;
            } else {
//                临_st_12 = "lot";
//                临_do_13 = 0.0;
//                临_do_14 = 0.0;
//                临_in_15 = 0;
//                临_in_16 = 0;
//                for (临_in_17 = OrdersTotal() - 1; 临_in_17 >= 0; 临_in_17 = 临_in_17 - 1) {
//                    if (!(OrderSelect(临_in_17, SELECT_BY_POS, MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
//                        continue;
//                    临_in_16 = OrderTicket();
//                    if (临_in_16 <= 临_in_15)
//                        continue;
//                    临_in_15 = 临_in_16;
//                    临_do_13 = OrderOpenPrice();
//                    临_do_14 = OrderLots();
//
//                }
//
//                if (临_st_12 == "lot") {
//                    临_do_18 = 临_do_14;
//                } else {
//                    临_do_18 = 0.0;
//                }
                //if ( 临_st_12 == "price" )
                //{
                //  临_do_18 = 临_do_13;
                //}
                //else
                //{
                //  if ( 临_st_12 == "lot" )
                //  {
                //    临_do_18 = 临_do_14;
                //  }
                //  else
                //  {
                //    临_do_18 = 0.0;
                //  }
                //}
                //UserLots = MathRound(临_do_18 / 子_2_do) * 子_2_do;
                UserLots = MathRound(counter.LastOrderLots / 子_2_do) * 子_2_do;
            }
            //     临_in_19 = 0;
            //     for (临_in_20 = 0 ; 临_in_20 < OrdersTotal() ; 临_in_20=临_in_20 + 1)
            //     {
            //       if ( !(OrderSelect(临_in_20,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
            //       临_in_19=临_in_19 + 1;
            //
            //     }
            //     if ( 临_in_19>=DiscreetMultiplier && UserLots==0.01 )
            if (counter.AllTotal >= DiscreetMultiplier && UserLots == 0.01) {
                UserLots = 0.02;
            }
        }
    } else {
        //   临_in_21 = -1;
        //   临_in_22 = 0;
        //   for (临_in_23 = OrdersTotal() - 1 ; 临_in_23 >= 0 ; 临_in_23=临_in_23 - 1)
        //   {
        //     if ( !(OrderSelect(临_in_23,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
        //
        //     if ( 临_in_21 <  0 )
        //     {
        //       临_in_22=临_in_22 + 1;
        //     }
        //     if ( OrderType() == 临_in_21 && 临_in_21 >= 0 )
        //     {
        //       临_in_22=临_in_22 + 1;
        //     }
        //     if ( OrderType() <= 1 && 临_in_21 == 8 )
        //     {
        //       临_in_22=临_in_22 + 1;
        //     }
        //     if ( OrderType() >  1 && 临_in_21 == 9 )
        //     {
        //       临_in_22=临_in_22 + 1;
        //     }
        //     if ( ( OrderType() == 0 || OrderType() == 2 || OrderType() == 4 ) && 临_in_21 == 6 )
        //     {
        //       临_in_22=临_in_22 + 1;
        //     }
        //     if ( ( OrderType() != 1 && OrderType() != 3 && OrderType() != 5 ) || 临_in_21 != 7 )   continue;
        //     临_in_22=临_in_22 + 1;
        //
        //   }
        //if ( 临_in_22 == 0 )
        if (counter.AllTotal == 0) {
            子_1_do = Lot;
        } else {
//            临_st_24 = "lot";
//            临_do_25 = 0.0;
//            临_do_26 = 0.0;
//            临_in_27 = 0;
//            临_in_28 = 0;
//            for (临_in_29 = OrdersTotal() - 1; 临_in_29 >= 0; 临_in_29 = 临_in_29 - 1) {
//                if (!(OrderSelect(临_in_29, SELECT_BY_POS, MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
//                    continue;
//                临_in_28 = OrderTicket();
//                if (临_in_28 <= 临_in_27)
//                    continue;
//                临_in_27 = 临_in_28;
//                临_do_25 = OrderOpenPrice();
//                临_do_26 = OrderLots();
//
//            }
//
//            if (临_st_24 == "lot") {
//                临_do_30 = 临_do_26;
//            } else {
//                临_do_30 = 0.0;
//            }

            //if ( 临_st_24 == "price" )
            //{
            //  临_do_30 = 临_do_25;
            //}
            //else
            //{
            //  if ( 临_st_24 == "lot" )
            //  {
            //    临_do_30 = 临_do_26;
            //  }
            //  else
            //  {
            //    临_do_30 = 0.0;
            //  }
            //}
            //子_1_do = MathRound(临_do_30 * Multiplier / 子_2_do) * 子_2_do;
            子_1_do = MathRound(counter.LastOrderLots * Multiplier / 子_2_do) * 子_2_do;
        }
        if (Multiplier > 1.0) {
            //     临_in_31 = -1;
            //     临_in_32 = 0;
            //     for (临_in_33 = OrdersTotal() - 1 ; 临_in_33 >= 0 ; 临_in_33=临_in_33 - 1)
            //     {
            //       if ( !(OrderSelect(临_in_33,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
            //
            //       if ( 临_in_31 <  0 )
            //       {
            //         临_in_32=临_in_32 + 1;
            //       }
            //       if ( OrderType() == 临_in_31 && 临_in_31 >= 0 )
            //       {
            //         临_in_32=临_in_32 + 1;
            //       }
            //       if ( OrderType() <= 1 && 临_in_31 == 8 )
            //       {
            //         临_in_32=临_in_32 + 1;
            //       }
            //       if ( OrderType() >  1 && 临_in_31 == 9 )
            //       {
            //         临_in_32=临_in_32 + 1;
            //       }
            //       if ( ( OrderType() == 0 || OrderType() == 2 || OrderType() == 4 ) && 临_in_31 == 6 )
            //       {
            //         临_in_32=临_in_32 + 1;
            //       }
            //       if ( ( OrderType() != 1 && OrderType() != 3 && OrderType() != 5 ) || 临_in_31 != 7 )   continue;
            //       临_in_32=临_in_32 + 1;
            //
            //     }
            //if ( 临_in_32 >  0 )
            if (counter.AllTotal > 0) {
                UserLots = NormalizeDouble(子_1_do, ModeLotstep);
            }
        }
        //   临_in_34 = 0;
        //   for (临_in_35 = 0 ; 临_in_35 < OrdersTotal() ; 临_in_35=临_in_35 + 1)
        //   {
        //     if ( !(OrderSelect(临_in_35,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
        //     临_in_34=临_in_34 + 1;
        //
        //   }
        // if ( 临_in_34 >= 1 && Multiplier>1.0 && UserLots==0.01 )
        if (counter.AllTotal >= 1 && Multiplier > 1.0 && UserLots == 0.01) {
            UserLots = 0.02;
        }
    }
    if (UserLots < MarketInfo(Symbol(), 23)) {
        UserLots = MarketInfo(Symbol(), 23);
    }
    if (!(UserLots > MarketInfo(Symbol(), 25)))
        return;
    UserLots = MarketInfo(Symbol(), 25);
}

//+------------------------------------------------------------------+
//| 抛物线移动止损                                                   |
//+------------------------------------------------------------------+
void 抛物线移动止损(const Indicator & ind, const Counter & counter) {
    double 子_1_do;
    int 子_2_in;
    int 子_3_in;
    int 子_4_in;
    int 子_5_in;
    double 子_6_do;
    double 子_7_do;
    //int 子_8_in; //循环
    int 子_9_in;
    int 子_10_in;
    //----- -----
    //int 临_in_1;
    //int 临_in_2;
    //int 临_in_3;
    //int 临_in_4;
    //int 临_in_5;
    //int 临_in_6;
    //int 临_in_7;
    //int 临_in_8;

    //总_28_do = iSAR(Symbol(),0,stepSAR,0.2,0) ;
    //总_29_do = iSAR(Symbol(),0,stepSAR,0.2,1) ;
    子_1_do = MarketInfo(Symbol(), 14) * ModeDigits;
    //OrderTypeStr = "" ;
    子_2_in = 0;
    子_3_in = 0; //
    子_4_in = 0; //改单结果
    子_5_in = 0; //统计单数
    子_6_do = 0.0; //当前价格
    子_7_do = 0.0; //总盈利
    //for (子_8_in = 0 ; 子_8_in < OrdersTotal() ; 子_8_in = 子_8_in + 1)
    //{
    //if ( !(OrderSelect(子_8_in,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
    //子_5_in = 子_5_in + 1;    //统计单数
    //子_7_do = 子_7_do + OrderProfit() ;  //总盈利
    if (UseTrailingSAR) {
        //     临_in_1 = 0;
        //     for (临_in_2 = 0 ; 临_in_2 < OrdersTotal() ; 临_in_2=临_in_2 + 1)
        //     {
        //       if ( !(OrderSelect(临_in_2,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
        //       临_in_1=临_in_1 + 1;
        //
        //     }
        //if ( 临_in_1 == 1 )
        if (counter.AllTotal == 1) {
            //子_6_do = OrderOpenPrice() ;
            子_6_do = counter.LastOrderOpenPrice;
            //if ( OrderTakeProfit()!=0.0 )
            if (counter.LastOrderTakeProfit != 0.0) {
                //子_4_in = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),0.0,0,0xFFFFFFFF) ;
                子_4_in = OrderModify(counter.LastOrderTicket, counter.LastOrderOpenPrice, counter.LastOrderStopLoss, 0.0, 0, 0xFFFFFFFF);
            }
            if (总_16_do != 0.0 && (Bid - 总_16_do > 子_1_do || 总_16_do - Ask > 子_1_do)) {
                //if ( OrderType() == 0 && Close[0]>TakeProfit * ModeDigits + OrderOpenPrice() && 总_16_do!=0.0 && OrderStopLoss()!=总_16_do )
                if (counter.LastOrderType == 0 && Close[0] > TakeProfit * ModeDigits + OrderOpenPrice() && 总_16_do != 0.0 && OrderStopLoss() != 总_16_do) {
                    //子_4_in = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(总_16_do,Digits),0.0,0,0xFFFFFFFF) ;
                    子_4_in = OrderModify(counter.LastOrderTicket, counter.LastOrderOpenPrice, NormalizeDouble(总_16_do, Digits), 0.0, 0, 0xFFFFFFFF);
                }
                //if ( OrderType() == 1 && Close[0]<OrderOpenPrice() - TakeProfit * ModeDigits && 总_16_do!=0.0 && OrderStopLoss()!=总_16_do )
                if (counter.LastOrderType == 1 && Close[0] < OrderOpenPrice() - TakeProfit * ModeDigits && 总_16_do != 0.0 && OrderStopLoss() != 总_16_do) {
                    //子_4_in = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(总_16_do,Digits),0.0,0,0xFFFFFFFF) ;
                    子_4_in = OrderModify(counter.LastOrderTicket, counter.LastOrderOpenPrice, NormalizeDouble(总_16_do, Digits), 0.0, 0, 0xFFFFFFFF);
                }
            }
        }
    }
    //if ( OrderType() == 0 )
    //{
    //  OrderTypeStr = "buy" ;
    //}
    //if ( OrderType() == 1 )
    //{
    //  OrderTypeStr = "sell" ;
    //}
    // OrderStopLoss()==0.0 continue;
    //if ( !(OrderStopLoss()!=0.0) )   continue;
    //子_3_in = 子_3_in + 1;

    //}
    //if ( 子_3_in != 0 )
    //{
    //  if ( ( ( OrderTypeStr == "buy" && Close[0]<ind.iSARFastLine ) || (OrderTypeStr == "sell" && Close[0]>ind.iSARFastLine) ) )
    //  {
    //    总_27_bo = true ;
    //  }
    //}
    //else
    //{
    //  总_27_bo = false ;
    //}
    总_16_do = 0.0;

    // OrderType => 0 buy | OrderType => 1 sell
    if (counter.LastOrderType == 0 && Open[0] > ind.iSARFastLine) {
        if ((ind.iSARFastLine >= 总_13_do || (counter.AllTotal == 1 && ind.iSARFastLine >= TakeProfit * ModeDigits + 子_6_do))) {
            for (子_9_in = 1; 子_9_in <= 20; 子_9_in = 子_9_in + 1) {
                总_15_do = iSAR(Symbol(), 0, stepSAR, 0.2, 子_9_in);
                if (总_15_do < Close[0]) {
                    子_2_in = 子_2_in + 1;
                }
                if (子_2_in >= levelSAR - 1)
                    break;
            }

            总_16_do = NormalizeDouble(总_15_do, Digits);
        }
    }

    if (counter.LastOrderType == 1 && Open[0] < ind.iSARFastLine) {
        if ((ind.iSARFastLine <= 总_13_do || (counter.AllTotal == 1 && ind.iSARFastLine <= 子_6_do - TakeProfit * ModeDigits))) {
            for (子_10_in = 1; 子_10_in <= 20; 子_10_in = 子_10_in + 1) {
                总_15_do = iSAR(Symbol(), 0, stepSAR, 0.2, 子_10_in);
                if (总_15_do > Close[0]) {
                    子_2_in = 子_2_in + 1;
                }
                if (子_2_in >= levelSAR - 1)
                    break;
            }

            总_16_do = NormalizeDouble(总_15_do, Digits);
        }
    }

    // 临_in_3 = 0;
    // if ( OrderTypeStr == "buy" && Open[0]>ind.iSARFastLine )
    // {
    //   for (临_in_4 = 0 ; 临_in_4 < OrdersTotal() ; 临_in_4=临_in_4 + 1)
    //   {
    //     if ( !(OrderSelect(临_in_4,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
    //     临_in_3=临_in_3 + 1;
    //
    //   }
    //   if ( ( ind.iSARFastLine>=总_13_do || (临_in_3 == 1 && ind.iSARFastLine>=TakeProfit * ModeDigits + 子_6_do) ) )
    //   {
    //     for (子_9_in = 1 ; 子_9_in <= 20 ; 子_9_in = 子_9_in + 1)
    //     {
    //       总_15_do = iSAR(Symbol(),0,stepSAR,0.2,子_9_in) ;
    //       if ( 总_15_do<Close[0] )
    //       {
    //         子_2_in = 子_2_in + 1;
    //       }
    //       if ( 子_2_in >= levelSAR - 1 )   break;
    //     }
    //     总_16_do = NormalizeDouble(总_15_do,Digits) ;
    //   }
    // }
    //
    // 临_in_5 = 0;
    // if ( OrderTypeStr == "sell" && Open[0]<ind.iSARFastLine )
    // {
    //   for (临_in_6 = 0 ; 临_in_6 < OrdersTotal() ; 临_in_6=临_in_6 + 1)
    //   {
    //     if ( !(OrderSelect(临_in_6,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
    //     临_in_5=临_in_5 + 1;
    //
    //   }
    //   if ( ( ind.iSARFastLine<=总_13_do || (临_in_5 == 1 && ind.iSARFastLine<=子_6_do - TakeProfit * ModeDigits) ) )
    //   {
    //     for (子_10_in = 1 ; 子_10_in <= 20 ; 子_10_in = 子_10_in + 1)
    //     {
    //       总_15_do = iSAR(Symbol(),0,stepSAR,0.2,子_10_in) ;
    //       if ( 总_15_do>Close[0] )
    //       {
    //         子_2_in = 子_2_in + 1;
    //       }
    //       if ( 子_2_in >= levelSAR - 1 )   break;
    //     }
    //     总_16_do = NormalizeDouble(总_15_do,Digits) ;
    //   }
    // }

    if (counter.LastOrderStopLoss > 0 && counter.AllProfit > 0.0) {
        if (counter.LastOrderType == 0 && ind.iSARFastLine > Open[0] && ind.iSARSlowLine < Open[0] && Close[0] > 总_13_do) {
            总_18_do = TakeProfit * ModeDigits + Close[0];
        }
        if (counter.LastOrderType == 1 && ind.iSARFastLine < Open[0] && ind.iSARSlowLine > Open[0] && Close[0] < 总_13_do) {
            总_17_do = Close[0] - TakeProfit * ModeDigits;
        }
    }

    //if ( 子_3_in >  0 && 子_7_do>0.0 )
    //{
    //  if ( OrderTypeStr == "buy" && ind.iSARFastLine>Open[0] && ind.iSARSlowLine<Open[0] && Close[0]>总_13_do )
    //  {
    //    总_18_do = TakeProfit * ModeDigits + Close[0] ;
    //  }
    //  if ( OrderTypeStr == "sell" && ind.iSARFastLine<Open[0] && ind.iSARSlowLine>Open[0] && Close[0]<总_13_do )
    //  {
    //    总_17_do = Close[0] - TakeProfit * ModeDigits ;
    //  }
    //}
    ObjectDelete("TargetTP");
    ObjectDelete("TP");
    // 临_in_7 = 0;
    // for (临_in_8 = 0 ; 临_in_8 < OrdersTotal() ; 临_in_8=临_in_8 + 1)
    // {
    //   if ( !(OrderSelect(临_in_8,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;
    //   临_in_7=临_in_7 + 1;
    //
    // }
    // if ( 临_in_7 == 1 )
    if (counter.AllTotal == 1) {
        总_13_do = TakeProfit * ModeDigits + 子_6_do;
    }
    ObjectCreate("TargetTP", OBJ_HLINE, 0, Time[1], 总_13_do, 0, 0.0, 0, 0.0);
    ObjectSet("TargetTP", OBJPROP_COLOR, 16777215.0);
    ObjectSet("TargetTP", OBJPROP_STYLE, 2.0);
    ObjectSet("TargetTP", OBJPROP_WIDTH, 2.0);
    ObjectSet("TargetTP", OBJPROP_BACK, 1.0);
    ObjectCreate("TP", OBJ_TEXT, 0, iTime(Symbol(), 1440, 1), (Ask - Bid) * 20.0 + 总_13_do, 0, 0.0, 0, 0.0);
    ObjectSetText("TP", "Level Take Profit", 10, "Arial", White);
}

//<<==抛物线移动止损 <<==

//+------------------------------------------------------------------+
//| 移动止损                                                         |
//+------------------------------------------------------------------+
void 移动止损() {
    int 子_1_in;
    //----- -----
    double 临_do_1;
    double 临_do_2;
    int 临_in_3;

    for (子_1_in = 0; 子_1_in < OrdersTotal(); 子_1_in = 子_1_in + 1) {
        if (!(OrderSelect(子_1_in, SELECT_BY_POS, MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber || !(UseTrailingStop) || !(TrailingStop > 0.0))
            continue;

        if (OrderType() == 0 && Bid - OrderOpenPrice() > TrailingStart * ModeDigits && TrailingStep * ModeDigits + OrderStopLoss() < NormalizeDouble(Bid - TrailingStop * ModeDigits, Digits) && OrderStopLoss() < NormalizeDouble(Bid - TrailingStop * ModeDigits, Digits) && OrderSelect(OrderTicket(), SELECT_BY_TICKET, MODE_TRADES) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() <= 1) {
            int rlt = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid - TrailingStop * ModeDigits, Digits), OrderTakeProfit(), 0, Gold);
            if (GetLastError() != 0) {
                Print("Error on Trail Order modify = ", ErrorDescription(GetLastError()));
            }
        }
        if (OrderType() != 1 || !(OrderOpenPrice() - Ask > TrailingStart * ModeDigits))
            continue;

        if (!(OrderStopLoss() == 0.0)) {
            临_do_1 = TrailingStop * ModeDigits;
            if (!(OrderStopLoss() - TrailingStep * ModeDigits > NormalizeDouble(TrailingStop * ModeDigits + Ask, Digits)))
                continue;
            临_do_1 = Ask + 临_do_1;
            if (!(OrderStopLoss() > NormalizeDouble(临_do_1, Digits)))
                continue;
        }
        临_do_2 = NormalizeDouble(TrailingStop * ModeDigits + Ask, Digits);
        if (!(OrderSelect(OrderTicket(), SELECT_BY_TICKET, MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber || OrderType() > 1)
            continue;
        int rlt = OrderModify(OrderTicket(), OrderOpenPrice(), 临_do_2, OrderTakeProfit(), 0, Gold);
        临_in_3 = GetLastError();
        if (临_in_3 == 0)
            continue;
        Print("Error on Trail Order modify = ", ErrorDescription(临_in_3));

    }
}

//+------------------------------------------------------------------+
//| 新闻权重加载                                                     |
//+------------------------------------------------------------------+
int 新闻权重加载() {
    double 子_2_do;
    int 子_3_in;
    int 子_4_in;
    int 子_5_in;
    int 子_6_in;
    string 子_7_st;
    string 子_8_st;
    string 子_9_st;
    string 子_10_st;
    string 子_11_st;
    int 子_12_in;
    int 子_13_in;
    //----- -----
    string 临_st_1;
    int 临_in_2;
    int 临_in_3;
    int 临_in_4;
    string 临_st_5;
    int 临_in_6;
    int 临_in_7;
    int 临_in_8;

    IsTesting();

    子_2_do = iCustom(Symbol(), 0, "NewsCal-v107_X", "", 1, "Calendar", 0, 1, 10, 0, 48, 1, 1, 0, 1, "", 1, 15, 60, "", IncludeLowImpact, IncludeMediumImpact, IncludeHighImpact, IncludeHolidays, IncludeMeetings, IncludeSpeeches, 0, CurrencyFilterList, 0, 0);
    子_3_in = 20000;
    子_4_in = 2000;
    子_5_in = 5000;

    for (子_6_in = 1; 子_6_in <= 10; 子_6_in = 子_6_in + 1) {
        子_7_st = "zNews LB Calendar~T" + IntegerToString(1, 0, 32);
        子_8_st = "zNews LB Calendar~N" + IntegerToString(1, 0, 32);
        子_9_st = "zNews LB Calendar~C" + IntegerToString(1, 0, 32);
        子_10_st = ObjectGetString(0, 子_7_st, 999, 0);
        NewsTitle = ObjectGetString(0, 子_8_st, 999, 0);
        子_11_st = ObjectGetString(0, 子_9_st, 999, 0);
        临_st_1 = 子_10_st;
        临_in_2 = StringLen(子_10_st);
        临_in_3 = 0;

        for (临_in_4 = 0; 临_in_4 < 临_in_2; 临_in_4 = 临_in_4 + 1) {
            临_in_3 = StringGetCharacter(临_st_1, 临_in_4);
            if (临_in_3 < 65 || 临_in_3 > 90)
                continue;
            临_st_1 = StringSetChar(临_st_1, 临_in_4, 临_in_3 + 32);
        }

        if (临_st_1 == "now" && NewsTimeCurrent == 0) {
            NewsTimeCurrent = TimeCurrent();
        }

        if (NFP_only && StringFind(NewsTitle, "Non-Farm", 0) == -1) {
            Comment("There are no \'Non-Farm\' News!");
            return (0);
        }

        临_st_5 = 子_10_st;
        临_in_6 = StringLen(子_10_st);
        临_in_7 = 0;

        for (临_in_8 = 0; 临_in_8 < 临_in_6; 临_in_8 = 临_in_8 + 1) {
            临_in_7 = StringGetCharacter(临_st_5, 临_in_8);
            if (临_in_7 < 65 || 临_in_7 > 90)
                continue;
            临_st_5 = StringSetChar(临_st_5, 临_in_8, 临_in_7 + 32);
        }

        if (临_st_5 == "now") {
            return (0);
        }

        if (StringFind(子_10_st, "m", 0) > 0 && StringToInteger(子_10_st) >= 0 && StringToInteger(子_10_st) <= 子_5_in) {
            子_5_in = StringToInteger(子_10_st);
            if (子_5_in < 子_3_in) {
                子_3_in = 子_5_in;
            }
        }

        if (StringFind(子_10_st, "h", 0) > 0) {
            子_12_in = StringToInteger(StringSubstr(子_10_st, 0, StringFind(子_10_st, "h", 0)));
            子_13_in = StringToInteger(StringSubstr(子_10_st, StringFind(子_10_st, "h", 0) + 1, StringLen(子_10_st) - (StringFind(子_10_st, "h", 0) + 1)));
            子_5_in = 子_12_in * 60 + 子_13_in;
            if (子_5_in < 子_3_in) {
                子_3_in = 子_5_in;
            }
        }
    }

    return (子_3_in);
}

//+------------------------------------------------------------------+
//| 显示字幕信息                                                     |
//+------------------------------------------------------------------+
void 显示字幕信息() {
    int 子_1_in;
    string 子_2_st;
    //----- -----

    子_1_in = 1;
    子_2_st = "[" + WindowExpertName() + "]";

    if (ObjectFind(子_2_st + string(1)) == -1) {
        ObjectCreate(子_2_st + string(1), OBJ_LABEL, 0, 0, 0.0, 0, 0.0, 0, 0.0);
        ObjectSet(子_2_st + string(1), OBJPROP_BACK, 0.0);
        ObjectSet(子_2_st + string(1), OBJPROP_COLOR, TextColor);
        ObjectSet(子_2_st + string(1), OBJPROP_CORNER, TextCorner);
        ObjectSet(子_2_st + string(1), OBJPROP_XDISTANCE, TextXAnchor);
        ObjectSet(子_2_st + string(1), OBJPROP_YDISTANCE, TextYFirst + TextYAnchor - TextYFirst / 2);
    }

    ObjectSetText(子_2_st + string(子_1_in), "BrokerTime: " + TimeToString(TimeCurrent(), 5), Textsize, FontName, 0xFFFFFFFF);
    子_1_in = 子_1_in + 1;

    if (ObjectFind(子_2_st + string(子_1_in)) == -1) {
        ObjectCreate(子_2_st + string(子_1_in), OBJ_LABEL, 0, 0, 0.0, 0, 0.0, 0, 0.0);
        ObjectSet(子_2_st + string(子_1_in), OBJPROP_BACK, 0.0);
        ObjectSet(子_2_st + string(子_1_in), OBJPROP_COLOR, TextColor);
        ObjectSet(子_2_st + string(子_1_in), OBJPROP_CORNER, TextCorner);
        ObjectSet(子_2_st + string(子_1_in), OBJPROP_XDISTANCE, TextXAnchor);
        ObjectSet(子_2_st + string(子_1_in), OBJPROP_YDISTANCE, TextYFirst + TextYAnchor * 子_1_in - TextYFirst / 2);
    }

    ObjectSetText(子_2_st + string(子_1_in), "GMTTime: " + TimeToString(TimeGMT(), 5), Textsize, FontName, 0xFFFFFFFF);
    子_1_in = 子_1_in + 1;

    if (ObjectFind(子_2_st + string(子_1_in)) == -1) {
        ObjectCreate(子_2_st + string(子_1_in), OBJ_LABEL, 0, 0, 0.0, 0, 0.0, 0, 0.0);
        ObjectSet(子_2_st + string(子_1_in), OBJPROP_BACK, 0.0);
        ObjectSet(子_2_st + string(子_1_in), OBJPROP_COLOR, TextColor);
        ObjectSet(子_2_st + string(子_1_in), OBJPROP_CORNER, TextCorner);
        ObjectSet(子_2_st + string(子_1_in), OBJPROP_XDISTANCE, TextXAnchor);
        ObjectSet(子_2_st + string(子_1_in), OBJPROP_YDISTANCE, TextYFirst + TextYAnchor * 子_1_in - TextYFirst / 2);
    }
    ObjectSetText(子_2_st + string(子_1_in), "Time Difference: " + string(LocalTimeSec) + " sec", Textsize, FontName, 0xFFFFFFFF);
    子_1_in = 子_1_in + 1;
    if (LocalTimeAdd > 0) {
        if (ObjectFind(子_2_st + string(子_1_in)) == -1) {
            ObjectCreate(子_2_st + string(子_1_in), OBJ_LABEL, 0, 0, 0.0, 0, 0.0, 0, 0.0);
            ObjectSet(子_2_st + string(子_1_in), OBJPROP_BACK, 0.0);
            ObjectSet(子_2_st + string(子_1_in), OBJPROP_COLOR, TextColor);
            ObjectSet(子_2_st + string(子_1_in), OBJPROP_CORNER, TextCorner);
            ObjectSet(子_2_st + string(子_1_in), OBJPROP_XDISTANCE, TextXAnchor);
            ObjectSet(子_2_st + string(子_1_in), OBJPROP_YDISTANCE, TextYFirst + TextYAnchor * 子_1_in - TextYFirst / 2);
        }
        ObjectSetText(子_2_st + string(子_1_in), "Seconds To News: " + string(LocalTimeAdd), Textsize, FontName, 0xFFFFFFFF);
        子_1_in = 子_1_in + 1;
    } else {
        if (ObjectFind(子_2_st + string(子_1_in)) == -1) {
            ObjectCreate(子_2_st + string(子_1_in), OBJ_LABEL, 0, 0, 0.0, 0, 0.0, 0, 0.0);
            ObjectSet(子_2_st + string(子_1_in), OBJPROP_BACK, 0.0);
            ObjectSet(子_2_st + string(子_1_in), OBJPROP_COLOR, TextColor);
            ObjectSet(子_2_st + string(子_1_in), OBJPROP_CORNER, TextCorner);
            ObjectSet(子_2_st + string(子_1_in), OBJPROP_XDISTANCE, TextXAnchor);
            ObjectSet(子_2_st + string(子_1_in), OBJPROP_YDISTANCE, TextYFirst + TextYAnchor * 子_1_in - TextYFirst / 2);
        }
        ObjectSetText(子_2_st + string(子_1_in), "Seconds To News: No News", Textsize, FontName, 0xFFFFFFFF);
        子_1_in = 子_1_in + 1;
    }
    if (ObjectFind(子_2_st + string(子_1_in)) == -1) {
        ObjectCreate(子_2_st + string(子_1_in), OBJ_LABEL, 0, 0, 0.0, 0, 0.0, 0, 0.0);
        ObjectSet(子_2_st + string(子_1_in), OBJPROP_BACK, 0.0);
        ObjectSet(子_2_st + string(子_1_in), OBJPROP_COLOR, Lime);
        ObjectSet(子_2_st + string(子_1_in), OBJPROP_CORNER, TextCorner);
        ObjectSet(子_2_st + string(子_1_in), OBJPROP_XDISTANCE, TextXAnchor);
        ObjectSet(子_2_st + string(子_1_in), OBJPROP_YDISTANCE, TextYFirst + TextYAnchor * 子_1_in - TextYFirst / 2);
    }
    ObjectSetText(子_2_st + string(子_1_in), "Next News: " + string(datetime(TimeLocal() + LocalTimeAdd)), Textsize, FontName, 0xFFFFFFFF);
    子_1_in = 子_1_in + 1;
}