// Programa   : REPBDLIST
// Fecha/Hora : 03/04/2004 11:30:37
// Prop�sito  : Presenta Lista de Tablas que Editadas
// Creado Por : Juan Navas
// Modificado : (Se agrega par�metro adicional para retornar el valor de dos campos "necesario para DPPOSDEVOL")
//              27/08/2014 JN, Parametro oControl, posiciona la caja de dialogo y asigna valor
// Llamado por: Rango/Reportes BDLIST()
// Aplicaci�n : Generador de Reportes
// Tabla      : DPREPORTES

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTable,aFields,lGroup,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oControl,oDb,lTotal,oFont)
   LOCAL uValue,I,cSql:="",oTable,nAt:=0,uValue2
   LOCAL aData:={},cGroup:="",cOr:=""
   LOCAL oDlgList,oBrw,oFontB,aLen:={},aDescri:={}
   LOCAL nClrPane1:=oDp:nClrPane1
   LOCAL nClrPane2:=oDp:nClrPane2
   LOCAL nClrText :=0,aPoint
   LOCAL nHeadLine:=1,bBlq,nAlto
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

 
   PRIVATE nWidth :=0 // Ancho Calculado seg�n Columnas 
   PRIVATE nHeight:=0 // Alto
   PRIVATE nLines :=0,nRow,nCol

   DEFAULT lGroup:=.T.,cWhere:="",cSgdoVal:=.F.

   DEFAULT oDb:=GETDBSERVER() 

   DEFAULT oDp:aFieldEn   :={"OPE_NOMBRE","OPE_CARGO"},;
           oDp:aPicture   :={},;
           oDp:aSize      :={},;
           oDp:lFullHeight:=.F.,;
           lTotal         :=.F.

   oDp:aBrwFind:={}

//? cTable,aFields,lGroup,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oControl,oDb,lTotal,oFont,"cTable,aFields,lGroup,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oControl,oDb,lTotal,oFont"

   IF !" WHERE "$cWhere
     cWhere :=STRTRAN(" "+cWhere," WHERE ","")
   ENDIF

   IF !" INNER "$cWhere
     // cWhere :=IIF( !Empty(cWhere) ," AND " , "")+cWhere
   ENDIF

   IF ValType(aTitle)="C"
      aTitle:=_VECTOR(aTitle)
   ENDIF

   cWhere:=" "+cWhere

   aFields:=IIF( ValType(aFields)="C",_VECTOR(aFields),aFields)

   oDp:aLine:={}

   CursorWait()

   IF cTable=NIL
      cTable :="DPINV"
      aFields:={"INV_CODIGO","INV_DESCRI"} 
      lGroup :=.F.
   ENDIF

   FOR I := 1 TO LEN(aFields) // Lista de los Campos
      cSql:=cSql+IIF( i=1, "" , ","   ) + ALLTRIM(aFields[i])
      cOr :=cOr +IIF( i=1, "" , " OR ") + "CAM_NAME"+GetWhere("=",aFields[I])
   NEXT

   cOr:="WHERE CAM_TABLE"+GetWhere("=",cTable)+" AND ("+cOr+")"

   oTable :=OpenTable("SELECT CAM_NAME,CAM_DESCRI,CAM_TYPE,CAM_LEN FROM DPCAMPOS  "+cOr,.T.)

   aDescri:=oTable:aDataFill
   oTable:End()

   IF lGroup

      // JN 27/08/2014

      IF Empty(cOrderBy)
         cOrderBy:=aFields[1]
      ENDIF

      cGroup:=cOrderBy

/*
      FOR I := 1 TO LEN(aFields) // Lista de los Campos
        cGroup:=cGroup+IIF( i=1, "" , ",") + ALLTRIM(aFields[i])
      NEXT
*/
      cGroup:=" GROUP BY "+cGroup
   ENDIF

   cSql:="SELECT "+cSql+" FROM "+cTable

   DEFAULT cOrderBy:=aFields[1]
       
   IF !Empty(cOrderBy)

      IF !"ORDER BY"$cOrderBy .AND. !Empty(cOrderBy)
         cOrderBy:=" ORDER BY "+cOrderBy
      ENDIF

   ENDIF
/*
   cSql:=cSql+;
         IIF(" WHERE "$cWhere, " ", " WHERE ") +cWhere+;
         IIF(" INNER "$cWhere, "" , IIF(Empty(cWhere),""," AND ")+aFields[1]+GetWhere("<>",""))+ ;
         cGroup+;       
         IIF(Empty(cOrderBy),""," ORDER BY "+cOrderBy)
*/

   cSql:=cSql+;
         IIF(" WHERE "$cWhere, " ", " WHERE ") +cWhere+;
         IIF(" INNER "$cWhere, "" , IIF(Empty(cWhere),""," AND ")+aFields[1]+GetWhere("<>",""))+ ;
         cGroup+;       
         IIF(Empty(cOrderBy),"",cOrderBy)

   oTable:=OpenTable(cSql,.T.,oDb)

   nLines:=MIN(oTable:RecCount(),19)
   aData :=ACLONE(oTable:aDataFill)

   IF !Empty(cFilter) .AND. !Empty(aData)
      aNew:={}
      cFilter:="{|a,n|IF("+cFilter+",AADD(aNew,a),NIL ) }) "

      cFilter:=MacroEje(cFilter)
      AEVAL(cFilter,aData)
   ENDIF

   oDp:aData:=ACLONE(aData)

   IF Empty(aData)
      oTable:End()

      cFind:=IF(cFind=NIL .AND. ValType(oControl)="O",EVAL(oControl:bSetGet),cFind)

      IF oControl=NIL
        MsgMemo("Informaci�n no Encontrada en "+CRLF+cTable+CRLF+GetFromVar("{oDp:"+cTable+"}"))
        RETURN cFind
      ENDIF

      IF "XBROW"$oControl:ClassName()
         EJECUTAR("XSCGMSGERR",oControl,ALLTRIM(cTable)+CRLF+GetFromVar("{oDp:"+cTable+"}")+CRLF+"Condici�n : "+ALLTRIM(cWhere),"Informaci�n no Encontrada ")
      ELSE
         oControl:MsgErr("Informaci�n no Encontrada en "+CRLF+cTable+CRLF+GetFromVar("{oDp:"+cTable+"}"),cTitle)
      ENDIF

      RETURN cFind
   ENDIF

   FOR I=1 TO LEN(oDp:aFieldEn)

     nAt:=ASCAN(oTable:aFields,{|a,n|a[1]=oDp:aFieldEn[I]})

     IF nAt>0
        AEVAL(aData,{|a,n| aData[n,nAt]:=ENCRIPT(a[nAt],.F.)})
     ENDIF

   NEXT I

// ViewArray(aData)

   AEVAL(oTable:aFields,{|a,i|AADD(aLen,a[3])})
  
   IF oFont=NIL
      DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   ENDIF

   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12  BOLD

   DEFAULT cTitle:=GetTableName(cTable)

   AEVAL(aTitle,{|a,n| aTitle[n]:=STRTRAN(a,";",CRLF)})

   IF ASCAN(aTitle,{|a,n| CRLF$a })>0
     nHeadLine:=2
   ENDIF

   IF ValType(oControl)="O"

      IF "XBROW"$oControl:ClassName()

        oBrw    :=oControl
        oCol    := oBrw:aCols[oBrw:nColSel]
        nRow    := ( ( oBrw:nRowSel - 1 ) * oBrw:nRowHeight ) + oBrw:HeaderHeight() + 2
        nCol    := oCol:nDisplayCol + 3
        nWidth  := oCol:nWidth - 4
        nHeight := oCol:oBrw:nRowHeight - 4
        aPoint  := { nRow, nCol }

        aPoint:= ClientToScreen( oBrw:hWnd, aPoint )

        aPoint[1]:=aPoint[1]+nHeight+1+10 // jn 01/09/2016
        aPoint[2]:=aPoint[2]-5         // jn 01/09/2016

      ELSE

        aPoint   := AdjustWnd( oControl, nWidth, nHeight )

      ENDIF

      DEFINE DIALOG oDlgList;
             TITLE cTitle;
             PIXEL OF oControl:oWnd;
             STYLE nOr( DS_SYSMODAL, DS_MODALFRAME )

   ELSE

      DEFINE DIALOG oDlgList TITLE cTitle FROM 1,30 TO 34,70

   ENDIF
 
   oDlgList:lHelpIcon:=.F.

   oBrw:=TXBrowse():New( oDlgList )

   oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
   oBrw:nHeaderLines        :=nHeadLine

//   oBrw:nColDividerStyle    := LINESTYLE_BLACK
//   oBrw:nRowDividerStyle    := LINESTYLE_BLACK
//   oBrw:lColDividerComplete := .t.
//   oBrw:bClrHeader          := {|| { 0,  12632256}}
   oBrw:SetArray( aData , .F. )
   oBrw:lHScroll            := .F.
   oBrw:oFont               :=oFont

//   oBrw:CreateFromCode()
//   oBrw:Refresh(.t.)

   FOR I := 1 TO LEN(oBrw:aCols)

      nAt :=ASCAN(aDescri,{|a| a[1]=ALLTRIM(oTable:FieldName(I)) })

      IF nAt>0
        oBrw:aCols[I]:cHeader:=LEFT(aDescri[nAt,2],aDescri[nAt,4])
      ELSE
         oBrw:aCols[I]:cHeader:=aFields[I] // oTable:aFieldName(I)
      ENDIF

      IF ValType(aTitle)="A" .AND. LEN(aTitle)<=LEN(oBrw:aCols)
         oBrw:aCols[I]:cHeader:=aTitle[I] 
      ENDIF

      IF ValType(aData[1,I])="N" // Alineaci�n Derecha

         oBrw:aCols[I]:nDataStrAlign:= AL_RIGHT
         oBrw:aCols[I]:nHeadStrAlign:= AL_RIGHT 

         IF LEN(oDp:aPicture)>=I .AND. !Empty(oDp:aPicture[I])
            bBlq:="{|nMonto|nMonto:=oBrw:aArrayData[oBrw:nArrayAt,"+LSTR(I)+"],FDP(nMonto,"+GetWhere("",oDp:aPicture[I])+")}"
            oBrw:aCols[I]:bStrData:=MACROEJE(bBlq)
         ENDIF

      ENDIF

      oBrw:aCols[I]:bLClickHeader := {|r,c,f,o| SortArray( o, oBrw:aArrayData ) } 

      IF LEN(oDp:aSize)>=I .AND. !Empty(oDp:aSize[I])
         oBrw:aCols[I]:nWidth:=oDp:aSize[I]
      ENDIF

      IF ValType(aData[1,I])="L"

          bBlq:="{|uValue|uValue:=oBrw:aArrayData[oBrw:nArrayAt,"+LSTR(I)+"],IIF( uValue , 1 , 2 )}"
          oBrw:aCols[I]:AddBmpFile(DPBMP("checkverde.bmp"))
          oBrw:aCols[I]:AddBmpFile(DPBMP("checkrojo.bmp"))
          oBrw:aCols[I]:bBmpData:=BloqueCod(bBlq)

          oBrw:aCols[I]:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
          oBrw:aCols[I]:bStrData    := {||""} 

      ENDIF


   NEXT

   oBrw:CreateFromCode()
   oBrw:Refresh(.t.)

   oTable:End()

   oBrw:bClrStd := {|| {nClrText, iif( oBrw:nArrayAt%2=0, nClrPane1  ,   nClrPane2 ) } }
   oBrw:SetFont(oFont)

   // 05-08-2008 Marlon Ramos (Retornar el valor de dos campos necesario para DPPOSDEVOL)
      //oBrw:bLDblClick:={||oDp:aLine:=ACLONE(aData[oBrw:nArrayAt]),uValue:=oBrw:aArrayData[oBrw:nArrayAt,1],oDlgList:End()}
      oBrw:bLDblClick:={||oDp:aLine:=ACLONE(aData[oBrw:nArrayAt]),uValue:=oBrw:aArrayData[oBrw:nArrayAt,1],uValue2:=IIF(LEN(aFields)>1,oBrw:aArrayData[oBrw:nArrayAt,2],""),oDlgList:End()}
   // Fin 05-08-2008 Marlon Ramos 

//   oBrw:bClrHeader:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
//   oBrw:bClrFooter:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oBrw:bKeyDown  := {|nkey,oBrw| IIF(nKey=107,EJECUTAR("REPBDLISTMAS",oBrw) ,NIL) }


   // Se removio ya que al darle enter en la seleccion del browse se guindaba el sistema
   /*
   oBrw:bKeyDown  := {|nkey,oBrw| IIF(nKey=13, EVAL(oBrw:bLDblClick),NIL),;
                                  IIF(nKey=107,EJECUTAR("REPBDLISTMAS",oBrw),NIL) }
   */

   AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})


   nWidth:=0 // jn 01/09/2016

   IF ValType(oControl)="O"

 
     ACTIVATE DIALOG oDlgList;
            ON INIT (REPBDBAR(oDlgList,oBrw,cFind),;
                     oDlgList:Move(aPoint[1] + 1, aPoint[2],nWidth+50,nHeight,.T.),;
                     oBrw:SetColor(nClrText, nClrPane1),;
                     SETALTURA(),;
                     oBrw:Move(50,0,nWidth+50-4,oDlgList:nHeight()-80,.t.),;
                     .F.)
/*
     ACTIVATE DIALOG oDlgList;
            ON INIT (REPBDBAR(oDlgList,oBrw,cFind),;
                     oDlgList:Move(aPoint[1] + 1, aPoint[2],NIL,NIL,.T.),;
                     oDlgList:SetSize(nWidth+50,nHeight),;
                     oBrw:SetColor(nClrText, nClrPane1),;
                     oBrw:Move(50,0,nWidth+50,nHeight-85,.t.),;
                     .F.)

*/

   ELSE

     ACTIVATE DIALOG oDlgList ON INIT (REPBDBAR(oDlgList,oBrw,cFind),;
                     oDlgList:Move(90,0,nWidth+9+40,nHeight+25,.T.),;
                     oBrw:Move(50,0,nWidth+40,nHeight-85,.t.),;
                     oBrw:SetColor(nClrText, nClrPane1))
   ENDIF


   IF cSgdoVal
      uValue:=CTOO(uValue) + "|||" + CTOO(uValue2)
   ENDIF

   IF !Empty(uValue) .AND. ValType(oControl)="O" .AND. "GET"$oControl:ClassName()
     oControl:VarPut(uValue,.T.)
   ENDIF

   oDp:lRepBdListCancel:=.F.

   oDp:aSize      :={}
   oDp:aPicture   :={}
   oDp:lFullHeight:=.F.

   // Presion� Salida , si devuelve NIL, genera incidencia
   IF uValue=NIL .AND. !Empty(cFind)
      oDp:lRepBdListCancel:=.T.
      uValue:=cFind
   ENDIF

RETURN uValue
/*
// Coloca la Barra de Botones
*/
FUNCTION REPBDBAR(oDlgList,oBrw,cFind)

   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif

   AEVAL(oBrw:aCols,{|o|o:nWidth:=MIN(o:nWidth,320),nWidth:=nWidth+o:nWidth+1})

   IF nWidth<175+32
      nDif:=175+32-nWidth
      oCol:=oBrw:aCols[Len(oBrw:aCols)]
      oCol:nWidth:=oCol:nWidth+nDif
      nWidth:=nWidth+nDif
   ENDIF

   IF ValType(cFind)=VALTYPE(aData[1,1])

      oBrw:nArrayAt:=MAX( ASCAN(aData,{|a|a[1]=cFind } ) ,1 )

   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-10,60-10 OF oDlgList 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oBrw,.F.)


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oBrw)

   oBtn:cToolTip:="Filtrar Registros"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oBrw);
          WHEN LEN(oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar seg�n Valores Comunes"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION EJECUTAR("BRWTOHTML",oBrw,NIL,cTitle)

   oBtn:cToolTip:="Generar Archivo html"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oBrw:GoTop(),oBrw:Setfocus())

//? nWidth,"nWidth"

IF nWidth>320+50

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oBrw:PageDown(),oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oBrw:PageUp(),oBrw:Setfocus())
ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oBrw:GoBottom(),oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oDlgList:End()

  AEVAL(oBar:aControls,{|o,n|o:SetColor(0,oDp:nGris)})
  oBar:SetColor(0,oDp:nGris)

  nHeight:=91+60+oBrw:nRowHeight+(oBrw:nRowHeight*nLines)+1

  IF !Empty(aPoint) .AND. oDp:lFullHeight

    nDif   :=(aCoors[3]-aPoint[1])
    nHeight:=nHeight+nDif
    IF nHeight>aCoors[3]
       nHeight:=nHeight-oDlgList:nTop()
    ENDIF

  ENDIF

RETURN .T.

FUNCTION SETALTURA()
  LOCAL nHeight
  LOCAL nMaxH:=GetCoors( GetDesktopWindow())[3]-50 // 1024 Maxima Capacidad del Video-Titulo-Menu-Area de Botones-Aerea de Mensajes
  LOCAL nDif // Diferencia extralimitada

  oDlgList:CoorsUpdate() // Actualiza ::nTop
  nHeight:=oDlgList:nTop+oDlgList:nHeight // Altura + Posici�n del Area de la Ventana MDI que Ocupa LBX
  nDif   :=nMaxH-nHeight

  // Reduce el Alto de la Ventana
  IF nDif<0
     oDlgList:SetSize(NIL,MAX(oDlgList:nHeight+nDif,110))
  ENDIF

RETURN 
//
