// Programa   : REPWRITE	
// Fecha/Hora : 13/03/2004 18:33:42
// Prop�sito  : Escribir Archivo .REP
// Creado Por : Juan Navas
// Llamado por: TGENREP
// Aplicaci�n : Generador de Informes	
// Tabla      : DPREPORTES

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep)
  LOCAL oIni,nLen:=0,cSql,cFileScr,nLenRup:=0
  LOCAL cFileOld,cFilePar,oTable

  IF oGenRep=NIL
     RETURN .T.
  ENDIF

  DEFAULT oGenRep:REP_PRNMOD :="",;
          oGenRep:REP_RPTTYPE:="",;
          oGenRep:REP_PRINTER:="",;
          oGenRep:REP_MAIL   :=.F.

  CursorWait()

  oGenRep:cMemo:=oGenRep:oMemo:GetText()

  cFileScr:=STRTRAN(oGenRep:cFileIni,".REP",".SRE")

  EJECUTAR("REPRUPTURA",oGenRep) // Order By para Rupturas de Control

  oGenRep:GetSql() // Genera Sintasix Sql

  cFilePar:=STRTRAN(UPPER(oGenRep:cFileIni),".REP",".RPR")
  Ferase(oGenRep:cFileIni)

//? oGenRep:cFileIni,FILE(oGenRep:cFileIni )

  oIni:=Tini():New( oGenRep:cFileIni )

  nLen   :=oIni:Get("HEAD","COLS"   ,nLen)
  nLenRup:=oIni:Get("HEAD","RUPT"   ,nLenRup)

  oIni:Set("HEAD","NAME"     ,oGenRep:REP_DESCRI    )
  oIni:Set("HEAD","DATE"     ,oGenRep:REP_FECHA     )
  oIni:Set("HEAD","HORA"     ,oGenRep:REP_HORA      )
//oIni:Set("HEAD","TIME"     ,oGenRep:dFecha      )
  oIni:Set("HEAD","COLS"     ,LEN(oGenRep:aCols)    )
  oIni:Set("HEAD","RANGOS"   ,LEN(oGenRep:aRango)   )
  oIni:Set("HEAD","CRITERIOS",LEN(oGenRep:aCriterio))
  oIni:Set("HEAD","RUPT"     ,LEN(oGenRep:aRuptura) )
  oIni:Set("HEAD","SQL"      ,oGenRep:cSql          )
  oIni:Set("HEAD","SQLSELECT",oGenRep:cSqlSelect    )
  oIni:Set("HEAD","SQLINNER ",oGenRep:cSqlInnerJoin )
  oIni:Set("HEAD","SQLORDER ",oGenRep:cSqlOrderBy   )
  oIni:Set("HEAD","SQLGROUP ",oGenRep:cSqlGroupBy   )
  oIni:Set("HEAD","ORDERRUPT",oGenRep:cOrderRupt    )
  oIni:Set("HEAD","GROUPBY"  ,oGenRep:lGroupBy      )
  oIni:Set("HEAD","SUM"      ,oGenRep:lSum          )
  oIni:Set("HEAD","NFIJAR"   ,oGenRep:nFijar        )

  // JN 25/08/2016
  oIni:Set("HEAD","REP_PRTMOD"     ,oGenRep:REP_PRTMOD  )
  oIni:Set("HEAD","REP_RPTTYPE"    ,oGenRep:REP_RPTTYPE )
  oIni:Set("HEAD","REP_PRINTER"    ,oGenRep:REP_PRINTER )
  oIni:Set("HEAD","REP_MAIL"       ,oGenRep:REP_MAIL    )
  oIni:Set("HEAD","REP_RGOCRIANDOR",oGenRep:cRgoCriAndOr) // 26/09/2016

  oIni:Set("HEAD","DEVICE",  IIF(oGenRep:lPreview ,"1" , "0" ) + "," +;
                             IIF(oGenRep:lPrinter ,"1" , "0" ) + "," +;
                             IIF(oGenRep:lVentana ,"1" , "0" ) + "," +;
                             IIF(oGenRep:lTxtWnd  ,"1" , "0" ) + "," +;
                             IIF(oGenRep:lExcel   ,"1" , "0" ) + "," +;
                             IIF(oGenRep:lDbf     ,"1" , "0" ) + "," +;
                             IIF(oGenRep:lHtml    ,"1" , "0" ) + "," +;
                             IIF(oGenRep:lCrystalP,"1" , "0" ) + "," +;
                             IIF(oGenRep:lCrystalW,"1" , "0" ) + "," +;
                             IIF(oGenRep:lPdfView ,"1" , "0" ) + "," +;
                             IIF(oGenRep:lPdfFile ,"1" , "0" ) + "," +;
                             IIF(oGenRep:lBrowse  ,"1" , "0" ))


  // Salva el Valor de las Columnas
  SAVESELECT(oGenRep,oIni) // Valor de Select

  // Salva el Valor de Order By
  SAVEORDER(oGenRep,oIni) // Valor de Select

  // Grabar Columnas
  SAVECOLS(oGenRep,oIni,nLen) 

  // Grabar Rango 
  nLen   :=oIni:Get("HEAD","RANGOS"   ,0)
  SAVERGO(oGenRep,oIni,nLen) 

  // Grabar Criterio
  nLen   :=oIni:Get("HEAD","CRITERIOS" ,0)
  SAVECRI(oGenRep,oIni,nLen) 

  // Grabar Enlaces
  SAVELINKS(oGenRep,oIni)

  // Grabar Grupos/Rupturas
  SAVERUP(oGenRep,oIni,nLenRup)

  // Grabar Crystal Report
  SAVERPT(oGenRep,oIni)

  oGenRep:cParameter:=MemoRead(oGenRep:cFileIni)

  // Valor de Columnas

  // DpMemoWrit(cFileScr,oGenRep:cMemo)
  DpWrite(cFileScr,oGenRep:cMemo)  
  // Debe borrar el compilado
  ferase(strtran(lower(cFileScr),".sre",".rxb"))

  IF oGenRep:cCodigoOld!=oGenRep:REP_CODIGO // Borrar el Archivo Anterior
    cFileOld:=STRTRAN(cFileScr,oGenRep:cCodigoOld,oGenRep:REP_CODIGO)
    FERASE(cFileOld)
  ENDIF

  COPY FILE (oGenRep:cFileIni) TO (cFilePar)

  CursorArrow()

  // Implementa Control de Versiones mediante tabla DPAUDITAELIMOD 14/02/2023
  IF oGenRep:nOption=3

     oTable:=OpenTable("SELECT * FROM DPREPORTES WHERE REP_CODIGO"+GetWhere("=",oGenRep:cCodigoOld),.T.)
     oTable:Replace("REP_FUENTE",oGenRep:cMemo     )
     oTable:Replace("REP_PARAM" ,oGenRep:cParameter)

     EJECUTAR("DPAUDELIMODTAB",oTable,"REP_CODIGO",oGenRep:cCodigoOld)

     oTable:Commit(oTable:cWhere)
     oTable:End()

  ENDIF


RETURN NIL

/*
// Graba los Campos del Select
*/
FUNCTION SAVESELECT(oGenRep,oIni)
  LOCAL aSelect:=oGenRep:aSelect,I,cLine:=""
  
  FOR I=1 TO LEN(aSelect)

     cLine:=cLine+IIF(I=1,"",";")+;
            "{"+PONCOMILLA(aSelect[I,1])+","+PONCOMILLA(aSelect[I,2])+","+PONCOMILLA(aSelect[I,3])+","+PONCOMILLA(aSelect[I,4])+"}"

  NEXT I

  // Se Guarda sin Llaves
  cLine:=REPSINLLAVES(cLine) // JN 08/06/2015 Separa Lineas por CHAR(8) y Campos por ,

  oIni:Set("HEAD","SELECT" ,cLine)

RETURN .T.

/*
// Graba los Campos del Select
*/
FUNCTION SAVEORDER(oGenRep,oIni)
  LOCAL aOrderBy:=oGenRep:aOrderBy,I,cLine:=""
  
  FOR I=1 TO LEN(aorderBy)

     cLine:=cLine+IIF(I=1,"",";")+;
            "{"+PONCOMILLA(aOrderBy[I,1])+","+PONCOMILLA(aOrderBy[I,2])+","+PONCOMILLA(aOrderBy[I,3])+","+PONCOMILLA(aOrderBy[I,4])+"}"

  NEXT I

  oIni:Set("HEAD","ORDERBY" ,cLine)

RETURN .T.

/*
// Graba Enlaces entre Tablas
*/
FUNCTION SAVELINKS(oGenRep,oIni)
  LOCAL aLinks:=oGenRep:aLinks,I,cLine:="",aLine
  
  FOR I=1 TO LEN(aLinks)

     aLine:=aLinks[I]

     IF Len(aLine)=4
        AADD(aLine,"INNER")
     ENDIF

     cLine:=cLine+IIF(I=1,"",";")+;
            "{"+PONCOMILLA(aLine[1])+",'',"+PONCOMILLA(aline[3])+",'',"+PONCOMILLA(aLine[5])+"}"

  NEXT I

  oIni:Set("HEAD","LINKS" ,cLine)

RETURN .T.

/*
// Graba las Columnas
*/
FUNCTION SAVECOLS(oGenRep,oIni,nLen)
   LOCAL I,oCol,cCol
   LOCAL cLine:=""

   FOR I=1 TO LEN(oGenRep:aCols)
      oCol :=oGenRep:aCols[I,7] 
      cCol :="COL"+STRZERO(I,2)
      oIni:Set(cCol,"FIELD"  ,oCol:cField  )
      oIni:Set(cCol,"TITLE1" ,oCol:cTitle1 )
      oIni:Set(cCol,"TITLE2" ,oCol:cTitle2 )
      oIni:Set(cCol,"EXP"    ,oCol:cExp    )
      oIni:Set(cCol,"EXP2"   ,oCol:cExp2   )
      oIni:Set(cCol,"EXP3"   ,oCol:cExp3   )
      oIni:Set(cCol,"TYPE"   ,oCol:cType   )
      oIni:Set(cCol,"TABLE"  ,oCol:cTable  )
      oIni:Set(cCol,"PICTURE",oCol:cPicture)
      oIni:Set(cCol,"LEN"    ,oCol:nLen    )
      oIni:Set(cCol,"DEC"    ,oCol:nDec    )
      oIni:Set(cCol,"SIZE"   ,oCol:nSize   )
      oIni:Set(cCol,"ALING"  ,oCol:nAling  )
      oIni:Set(cCol,"TOTAL"  ,oCol:lTotal  )
      oIni:Set(cCol,""       ,""           )
   NEXT I

   // Borra Columnas Inutilizados
   FOR I=LEN(oGenRep:aCols)+1 TO nLen
     cCol :="COL"+STRZERO(I,2)
     oIni:DelSection( cCol )
   NEXT I

RETURN NIL

/*
// Grabar RANGO
*/
FUNCTION SAVERGO(oGenRep,oIni,nLen)
   LOCAL I,oRgo,cRgo
   LOCAL cLine:="",cRgoIni

   FOR I=1 TO LEN(oGenRep:aRango)
      oRgo   :=oGenRep:aRango[I,6] 
      cRgo   :="RGO"+STRZERO(I,2)
      cRgoIni:=oRgo:cRgoIni

      IF '"'$cRgoIni
        cRgoIni:='['+cRgoIni+']'
      ENDIF

      oIni:Set(cRgo,"FIELD"   ,oRgo:cField   )
      oIni:Set(cRgo,"TITLE"   ,oRgo:cTitle   )
      oIni:Set(cRgo,"TYPE"    ,oRgo:cType    )
      oIni:Set(cRgo,"TABLE"   ,oRgo:cTable   )
      oIni:Set(cRgo,"PICTURE" ,oRgo:cPicture )
      oIni:Set(cRgo,"WHEN"    ,oRgo:cWhen    )
      oIni:Set(cRgo,"VALID"   ,oRgo:cValid   )
      oIni:Set(cRgo,"ACTION"  ,oRgo:cAction  )
      oIni:Set(cRgo,"MSG"     ,oRgo:cMsg     )
      oIni:Set(cRgo,"OPERATOR",oRgo:cOperator)
      oIni:Set(cRgo,"EDITTYPE",oRgo:nEditType)
      oIni:Set(cRgo,"DEC"     ,oRgo:nDec     )
      oIni:Set(cRgo,"LEN"     ,oRgo:nLen     )
      oIni:Set(cRgo,"ZERO"    ,oRgo:lZero    )
      oIni:Set(cRgo,"LIST"    ,oRgo:lList    )  // Lista de Opciones
      oIni:Set(cRgo,"EMPTY"   ,oRgo:lEmpty   )  // Rango Acepta Vacio
      oIni:Set(cRgo,"RGOINI"  ,PONCOMILLA(oRgo:cRgoIni)) // Valor Inicial     
      oIni:Set(cRgo,"RGOFIN"  ,PONCOMILLA(oRgo:cRgoFin)) // Valor Final       
      oIni:Set(cRgo,""       ,"")

   NEXT I

   // Borra Columnas Inutilizados
   FOR I=LEN(oGenRep:aRango)+1 TO nLen
     cRgo:="RGO"+STRZERO(I,2)
     oIni:DelSection( cRgo )
   NEXT I

RETURN NIL

/*
// Graba Grupos [Rupturas]
*/
FUNCTION SAVERUP(oGenRep,oIni,nLen)
   LOCAL I,oRup,cRup
   LOCAL cLine:=""

   FOR I=1 TO LEN(oGenRep:aRuptura)
      oRup :=oGenRep:aRuptura[I,3] 
      cRup :="RUP"+STRZERO(I,2)
      oIni:Set(cRup,"TITLE"   ,oRup:cTitle   )
      oIni:Set(cRup,"EXP"     ,oRup:cExp     )
      oIni:Set(cRup,"REPRES"  ,oRup:cRepres  )
      oIni:Set(cRup,"PAGE"    ,oRup:lPage    )
      oIni:Set(cRup,"LINES"   ,oRup:lLines   )
      oIni:Set(cRup,"NEWLINE" ,oRup:lNewLine ) 
      oIni:Set(cRup,"SUMARIZA",oRup:lSumariza) 
      oIni:Set(cRup,""        ,""            )
   NEXT I

   // Borra Columnas Inutilizados
   FOR I=LEN(oGenRep:aRuptura)+1 TO nLen
     cRup :="RUP"+STRZERO(I,2)
     oIni:DelSection( cRup )
   NEXT I

RETURN NIL


/*
// Grabar CRITERIO
*/
FUNCTION SAVECRI(oGenRep,oIni,nLen)
   LOCAL I,oCri,cCri
   LOCAL cLine:=""

   FOR I=1 TO LEN(oGenRep:aCriterio)

      oCri :=oGenRep:aCriterio[I,6]
      cCri :="CRI"+STRZERO(I,2)

      oIni:Set(cCri,"FIELD"   ,oCri:cField   )
      oIni:Set(cCri,"TITLE"   ,oCri:cTitle   )
      oIni:Set(cCri,"TYPE"    ,oCri:cType    )
      oIni:Set(cCri,"TABLE"   ,oCri:cTable   )
      oIni:Set(cCri,"PICTURE" ,oCri:cPicture )
      oIni:Set(cCri,"WHEN"    ,oCri:cWhen    )
      oIni:Set(cCri,"VALID"   ,oCri:cValid   )
      oIni:Set(cCri,"ACTION"  ,oCri:cAction  )
      oIni:Set(cCri,"CRIINI"  ,PONCOMILLA(oCri:cCriIni) )
      oIni:Set(cCri,"MSG"     ,oCri:cMsg     )
      oIni:Set(cCri,"OPERATOR",oCri:cOperator)
      oIni:Set(cCri,"RELATION",oCri:cRelation)
      oIni:Set(cCri,"EDITTYPE",oCri:nEditType)
      oIni:Set(cCri,"DEC"     ,oCri:nDec     )
      oIni:Set(cCri,"LEN"     ,oCri:nLen     )
      oIni:Set(cCri,"ZERO"    ,oCri:lZero    )
      oIni:Set(cCri,"LIST"    ,oCri:lList    ) // Lista de Opciones
      oIni:Set(cCri,"EMPTY"   ,oCri:lEmpty   ) // Rango Acepta Vacio
      oIni:Set(cCri,""       ,"")

   NEXT I

   // Borra Columnas Inutilizados
   FOR I=LEN(oGenRep:aCriterio)+1 TO nLen
     cCri :="CRI"+STRZERO(I,2)
     oIni:DelSection( cCri )
   NEXT I

RETURN NIL

/*
// Graba Archivos Crystal  
*/
FUNCTION SAVERPT(oGenRep,oIni)
  LOCAL aFilesRpt:=oGenRep:aFilesRpt,I,cLine:="",aLine
 
  FOR I=1 TO LEN(oGenRep:aFilesRpt)

     aLine:=oGenRep:aFilesRpt[I]

     IF LEN(aLine)=3
        AADD(aLine,.F.)
     ENDIF
     // JN 21/06/2016 CREXPORT
     cLine:=cLine+IIF(I=1,"",";")+;
            "{"+PONCOMILLA(aLine[1])+","+PONCOMILLA(aline[2])+",''"+","+IF(aLine[4],".T.",".F.")+"}"


  NEXT I

  oIni:Set("HEAD","CRYSTAL" ,cLine)

RETURN .T.


/*
FUNCTION SAVERPT(oGenRep,oIni)
  LOCAL aFilesRpt:=oGenRep:aFilesRpt,I,cLine:="",aLine
  LOCAL oTable:=OpenTable("SELECT * FROM DPREPORTESRPT",.F.)
  LOCAL aFiles:={}

//ViewArray(oGenRep:aFilesRpt)
  SQLDELETE("DPREPORTESRPT","RPT_CODIGO"+GetWhere("=",oGenRep:REP_CODIGO))
 
  FOR I=1 TO LEN(oGenRep:aFilesRpt)

     aLine:=oGenRep:aFilesRpt[I]
     aFiles:=DIRECTORY(aLine[1])

//ViewArray(aFiles)

     oTable:AppendBlank()

     oTable:Replace("RPT_CODIGO",oGenRep:REP_CODIGO)
     oTable:Replace("RPT_FILE"  ,aLine[1]          )
     oTable:Replace("RPT_ALTER" ,.T.               )

     oTable:Commit()

    
     cLine:=cLine+IIF(I=1,"",";")+;
            "{"+PONCOMILLA(aLine[1])+","+PONCOMILLA(aline[2])+",''}"

  NEXT I

  oIni:Set("HEAD","CRYSTAL" ,cLine)

RETURN .T.
*/

FUNCTION PONCOMILLA(uValue)
   uValue:=CTOO(uValue,"C")
   uValue:=ALLTRIM(uValue) // JN 08/06/2015
RETURN "'"+uValue+"'"

FUNCTION REPSINLLAVES(cMemo)

    IF LEFT(ALLTRIM(cMemo),1)="{"
      cMemo:=STRTRAN(cMemo,"};{",CHR(08))
      cMemo:=STRTRAN(cMemo,"}","")
      cMemo:=STRTRAN(cMemo,"{","")
      cMemo:=STRTRAN(cMemo,[","],",")
      cMemo:=STRTRAN(cMemo,['],"")
    ENDIF

RETURN cMemo

// EOF

