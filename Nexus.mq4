#property copyright "NexusOP"
#property link      "https:
#property version   "1.00"



extern double    Risk             =0.1;   
extern double    StopLossProcent  =20;
extern double    Tral             =20;   
extern double    TralStart        =3;   
extern double    TimeStart        =1;   
extern double    TimeEnd          =23;   
extern double    PipsStep         =4;   
extern double    Magic            =2021; 
extern bool      Info             =true;   
extern color     TextColor        =White;    
extern color     InfoDataColor    =DodgerBlue; 
extern color     FonColor         =Black;    
extern int       FontSizeInfo     =7;       



string           Commemt          ="NexusOP";
int              D,o;
double           Lot              =0;
double           Slb,Sls;
double           spread;
datetime         NewBar           =0;



int OnInit()
{
EventSetMillisecondTimer(100);
D=1;
if (Digits==5 || Digits==3)
{D=10;}
return(INIT_SUCCEEDED);
}



void OnDeinit(const int reason)
{
EventKillTimer();
ObjectsDeleteAll(0,OBJ_LABEL);
ObjectsDeleteAll(0,OBJ_RECTANGLE_LABEL);
}



void OnTick()
{

Lot=NormalizeDouble(AccountBalance()/10*Risk/(MarketInfo(Symbol(),MODE_TICKVALUE)*100*D),2);
if(Lot<MarketInfo(Symbol(),MODE_MINLOT)) {Lot=MarketInfo(Symbol(),MODE_MINLOT);} 
if(Lot>=MarketInfo(Symbol(),MODE_MAXLOT)) {Lot=MarketInfo(Symbol(),MODE_MAXLOT);}

bool GoBuy =false;
bool GoSell =false;

bool buy =false;
bool sell =false;

if(iOpen(Symbol(),0,0)>iClose(Symbol(),0,0) && AverageBar(1000)*PipsStep<(iOpen(Symbol(),0,0)-iClose(Symbol(),0,0))/Point)
{
sell=true;
}

if(iOpen(Symbol(),0,0)<iClose(Symbol(),0,0) && AverageBar(1000)*PipsStep<(iClose(Symbol(),0,0)-iOpen(Symbol(),0,0))/Point)
{
buy=true; 
}
  
if(TimeHour(TimeCurrent())>=TimeStart && TimeHour(TimeCurrent())<TimeEnd)
{    
if(buy) {GoBuy=true;}
if(sell) {GoSell=true;}    
} 

spread=(Ask-Bid)/Point;


double LossProc=(AccountBalance()/100)*StopLossProcent*(-1);
if(ProfitAll(-1)<LossProc && LossProc!=0)
{
ClosePos(Magic);
ObjectsDeleteAll(0,OBJ_ARROW);
ObjectsDeleteAll(0,OBJ_TREND);
}

if(Count(OP_BUY)==0 && CountHistBar(-1)==0 && CountBar(-1)==0 && GoSell && AccountFreeMarginCheck(Symbol(),OP_SELL,Lot)>0)
{o=OrderSend(Symbol(),OP_SELL,Lot,Bid,5,0,0,Commemt,Magic,0,Red);}

if(Count(OP_SELL)==0 && CountHistBar(-1)==0 && CountBar(-1)==0 && GoBuy && AccountFreeMarginCheck(Symbol(),OP_BUY,Lot)>0)
{o=OrderSend(Symbol(),OP_BUY,Lot,Ask,5,0,0,Commemt,Magic,0,Green);}

if(Count(OP_BUY)>0 || Count(OP_SELL)>0) {Traling();}

if(Info)
{
   RectLabelCreate3("INFO_fon",220,20,200,225,FonColor);
   
   PutLabel("INFO_LOGO",165,24,"WWW.NexusOP");
   PutLabel("INFO_Line",215,27,"___________________________");
   PutLabel_("INFO_txt1",215,45,"Account information");
   PutLabel("INFO_Line2",215,47,"___________________________");
   PutLabel("INFO_txt2",215,65,"Minimum stop:");
   PutLabel("INFO_txt3",215,80,"Spread:");
   PutLabel("INFO_txt4",215,95,"Balanse:");
   PutLabel("INFO_txt5",215,110,"Equity:");
   PutLabel("INFO_Line3",215,112,"___________________________");
   PutLabel_("INFO_txt6",215,130,"Profit on account");
   PutLabel("INFO_Line4",215,132,"___________________________");
   PutLabel("INFO_txt7",215,150,"Profit on pair:");
   PutLabel("INFO_txt8",215,165,"Total profit:");
   PutLabel("INFO_txt9",215,180,"Profit for today:");
   PutLabel("INFO_txt10",215,195,"Profit for yesterday:");
   PutLabel("INFO_txt11",215,210,"Profit for week:");
   PutLabel("INFO_txt12",215,225,"Profit for month:");
   
   PutLabel_("INFO_txt13",85,65,MarketInfo(Symbol(),MODE_STOPLEVEL));
   PutLabel_("INFO_txt14",85,80,(Ask-Bid)/Point);
   PutLabel_("INFO_txt15",85,95,AccountBalance());
   PutLabel_("INFO_txt16",85,110,AccountEquity());
   PutLabel_("INFO_txt17",85,150,Profit(-1));
   PutLabel_("INFO_txt18",85,165,ProfitAll(-1));
   PutLabel_("INFO_txt19",85,180,ProfitDey(-1));
   PutLabel_("INFO_txt20",85,195,ProfitTuDey(-1));
   PutLabel_("INFO_txt21",85,210,ProfitWeek(-1));
   PutLabel_("INFO_txt22",85,225,ProfitMontag(-1));
}

}




void ClosePos(int key)
{bool cl;
 for(int i=OrdersTotal()-1;i>=0;i--)
{if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
{if(OrderMagicNumber()==key)
{if(OrderType()==0)
{RefreshRates();
 cl=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID),Digits),10,White);}
if(OrderType()==1)
{RefreshRates();
 cl=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK),Digits),10,White);}}}}}

double AverageBar(int countCandles)
{
double size=0;
double returnSize=0;
for(int i=1; i<=countCandles; i++) 
{
size+=(iHigh(Symbol(),0,i)-iLow(Symbol(),0,i))/Point;
}
returnSize=size/countCandles;
return(returnSize);
}

int CountHistBar(int type)
{
int count=0;
for(int i=OrdersHistoryTotal()-1;i>=0;i--)
 if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
  {
  if(Symbol()==OrderSymbol() && OrderMagicNumber()==Magic && OrderCloseTime()>=iTime(Symbol(),0,0) && (type==-1 || OrderType()==type)) 
  {
  count++;
  }
  }
return(count);}

int CountBar(int type)
{
int count=0;
for(int i=OrdersTotal()-1;i>=0;i--)
 if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
  {
  if(Symbol()==OrderSymbol() && OrderMagicNumber()==Magic && OrderOpenTime()>=iTime(Symbol(),0,0) && (type==-1 || OrderType()==type)) 
  {
  count++;
  }
  }
return(count);}

void ModOrder()
{int tic;
 bool mod;
for(int i=OrdersTotal()-1;i>=0;i--)
if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
{if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
{
tic=OrderTicket();

if (OrderType()==OP_BUY && OrderStopLoss()==0)
{mod=OrderModify(tic,OrderOpenPrice(),Slb,OrderTakeProfit(),0);}

if (OrderType()==OP_SELL && OrderStopLoss()==0)
{mod=OrderModify(tic,OrderOpenPrice(),Sls,OrderTakeProfit(),0);}
}}}

void Traling()
{int tic;
 double Price;
 double Stop;
 bool mod;
for(int i=OrdersTotal()-1;i>=0;i--)
if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
{if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
{
tic=OrderTicket();
Price=OrderOpenPrice();
Stop=OrderStopLoss();

if (OrderType()==OP_BUY && Tral!=0)
   {if((Stop<Price || Stop==0) && Bid-(Tral+TralStart)*Point>=Price)
      {mod=OrderModify(tic,OrderOpenPrice(),Price+TralStart*Point,OrderTakeProfit(),0);}
    if(Stop>=Price && Bid-Tral*Point>Stop)
      {mod=OrderModify(tic,OrderOpenPrice(),Bid-Tral*Point,OrderTakeProfit(),0);}}

if (OrderType()==OP_SELL && Tral!=0)
   {if((Stop>Price  || Stop==0) && Ask+(Tral+TralStart)*Point<=Price)
      {mod=OrderModify(tic,OrderOpenPrice(),Price-TralStart*Point,OrderTakeProfit(),0);}
    if(Stop<=Price && Ask+Tral*Point<Stop)
      {mod=OrderModify(tic,OrderOpenPrice(),Ask+Tral*Point,OrderTakeProfit(),0);}}
}}}


int Count(int type)
{
int count=0;
for(int i=OrdersTotal()-1;i>=0;i--)
 if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
  {
  if(Symbol()==OrderSymbol() && Magic==OrderMagicNumber() && (type==-1 || OrderType()==type)) 
  {
  count++;
  }
  }
return(count);}

double Profit(int type) 
{double Profit = 0;
 for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
 if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
{if (Symbol()==OrderSymbol() && OrderMagicNumber()==Magic && (OrderType() == type || type==-1)) Profit += OrderProfit()+OrderSwap()+OrderCommission();}}
return (Profit);}


double ProfitAll(int type) 
{double Profit = 0;
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
      {if (OrderMagicNumber()==Magic && (OrderType() == type || type==-1)) Profit += OrderProfit()+OrderSwap()+OrderCommission();}}
       return (Profit);}
       

double ProfitDey(int type) 
{double Profit = 0;
   for (int cnt = OrdersHistoryTotal() - 1; cnt >= 0; cnt--) {
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY))
      {if (OrderMagicNumber()==Magic && OrderCloseTime()>=iTime(Symbol(),1440,0) && (OrderType() == type || type==-1)) Profit += OrderProfit()+OrderSwap()+OrderCommission();}}
       return (Profit);}
       

double ProfitTuDey(int type) 
{double Profit = 0;
   for (int cnt = OrdersHistoryTotal() - 1; cnt >= 0; cnt--) {
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY))
      {if (OrderMagicNumber()==Magic && OrderCloseTime()>=iTime(Symbol(),1440,1) && OrderCloseTime()<iTime(Symbol(),1440,0) && (OrderType() == type || type==-1)) Profit += OrderProfit()+OrderSwap()+OrderCommission();}}
       return (Profit);}
       

double ProfitEsTuDey(int type) 
{double Profit = 0;
   for (int cnt = OrdersHistoryTotal() - 1; cnt >= 0; cnt--) {
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY))
      {if (OrderMagicNumber()==Magic && OrderCloseTime()>=iTime(Symbol(),1440,2) && OrderCloseTime()<iTime(Symbol(),1440,1) && (OrderType() == type || type==-1)) Profit += OrderProfit()+OrderSwap()+OrderCommission();}}
       return (Profit);}
       

double ProfitWeek(int type) 
{double Profit = 0;
   for (int cnt = OrdersHistoryTotal() - 1; cnt >= 0; cnt--) {
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY))
      {if (OrderMagicNumber()==Magic && OrderCloseTime()>=iTime(Symbol(),10080,0) && (OrderType() == type || type==-1)) Profit += OrderProfit()+OrderSwap()+OrderCommission();}}
       return (Profit);}
       

double ProfitMontag(int type) 
{double Profit = 0;
   for (int cnt = OrdersHistoryTotal() - 1; cnt >= 0; cnt--) {
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY))
      {if (OrderMagicNumber()==Magic && OrderCloseTime()>=iTime(Symbol(),43200,0) && (OrderType() == type || type==-1)) Profit += OrderProfit()+OrderSwap()+OrderCommission();}}
       return (Profit);}
       

void PutLabel(string name,int x,int y,string text)
  {ObjectCreate(0,name,OBJ_LABEL,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

   ObjectSetInteger(0,name,OBJPROP_CORNER,1);

   ObjectSetString(0,name,OBJPROP_TEXT,text);

   ObjectSetString(0,name,OBJPROP_FONT,"Arial");

   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FontSizeInfo);

   ObjectSetInteger(0,name,OBJPROP_COLOR,TextColor);

   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);

   ObjectSetInteger(0,name,OBJPROP_BACK,false);}

void PutLabel_(string name,int x,int y,string text)
  {ObjectCreate(0,name,OBJ_LABEL,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

   ObjectSetInteger(0,name,OBJPROP_CORNER,1);

   ObjectSetString(0,name,OBJPROP_TEXT,text);

   ObjectSetString(0,name,OBJPROP_FONT,"Arial");

   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FontSizeInfo);

   ObjectSetInteger(0,name,OBJPROP_COLOR,InfoDataColor);

   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);

   ObjectSetInteger(0,name,OBJPROP_BACK,false);}
   

bool RectLabelCreate3(string  name, int x,int y, int width, int height, color back_clr)
  {ResetLastError(); 

if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0)) 
  {return(false);} 

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y); 

   ObjectSetInteger(0,name,OBJPROP_XSIZE,width); 
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height); 

   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,back_clr); 

   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_SUNKEN); 

   ObjectSetInteger(0,name,OBJPROP_CORNER,1); 

   ObjectSetInteger(0,name,OBJPROP_COLOR,Blue); 

   ObjectSetInteger(0,name,OBJPROP_WIDTH,1); 

   ObjectSetInteger(0,name,OBJPROP_BACK,false); 

   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false); 

return(true);} 

void OnTimer()
  {
   RefreshRates();
   OnTick();
  }
