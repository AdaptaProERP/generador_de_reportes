// Programa   : REPGETSQL
// Fecha/Hora : 14/03/2004 18:04:27
// Prop�sito  : Genera el C�digo Sql
// Creado Por : Juan Navas
// Llamado por: TGENREP
// Aplicaci�n : Generador de Informes
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep)
  LOCAL cSql:="",I,aLine,cLine
  LOCAL cLinkA,cLinkB,cTypeI:=""
  LOCAL cGroup:=""
  LOCAL cInner:=""

  FOR I=1 TO LEN(oGenRep:aSelect)

     aLine:=oGenRep:aSelect[I]
     cLine:=ALLTRIM(aLine[1])

     IF aLine[2]="N" .AND. oGenRep:lGroupBy
//      cLine:="SUM("+aLine[1]+"."+cLine+") AS "+cLine
//      cGroup:=cGroup+IIF(Empty(cGroup),"",",")+"SUM("+aLine[1]+")"
        cGroup:=cGroup+IIF(Empty(cGroup),"",",")+aLine[1]
     ENDIF

     IF aLine[2]="N" .AND. oGenRep:lSum .AND. !oGenRep:lGroupBy
       cLine:="SUM("+ALLTRIM(aLine[4])+"."+ALLTRIM(aLine[1])+") AS "+cLine
//? aLine[1],aLine[2],aLine[3],aLine[4]
//       cGroup:=cGroup+IIF(Empty(cGroup),"",",")+"SUM("+aLine[1]+")"
//       cGroup:=cGroup+IIF(Empty(cGroup),"",",")+aLine[1]
     ENDIF


     IF aLine[2]!="N" .AND. (oGenRep:lGroupBy .OR. oGenRep:lSum)

        cGroup:=cGroup+IIF(Empty(cGroup),"",",")+aLine[1]

     ENDIF

     IF ALLTRIM(aLine[1])!=ALLTRIM(aLine[3])
        cLine:=ALLTRIM(cLine)+" AS "+ALLTRIM(aLine[3])
     ELSE
        cLine:=IIF("("$cLine,"",ALLTRIM(aLine[4])+".")+ALLTRIM(cLine)
     ENDIF

     cSql:=cSql+IIF(I=1,"",",")+cLine

  NEXT I

  cSql:="SELECT "+cSql+" FROM "+ALLTRIM(oGenRep:REP_TABLA)

  oGenRep:cSqlGroupBy:=cGroup

  oGenRep:cSelect    :=cSql // Convierte el Select
  oGenRep:cSqlSelect :=cSql

// ViewArray(oGenRep:aLinks)

  // Genera Inner Join
  FOR I=1 TO LEN(oGenRep:aLinks)

     aLine :=oGenRep:aLinks[I]

//    ? aLine[1],aLine[2],aLine[3],aLine[4],UPPE(ALLTRIM(aLine[3]))!="NINGUNO"

     IF !EMPTY(aLine[3]) .AND. UPPE(ALLTRIM(aLine[3]))!="NINGUNO"

       cLinkA:=GetLinkTable(aLine[1],aLine[3],1)   
       cLinkB:=GetLinkTable(aLine[1],aLine[3],2)
   
       cLinkA:=PUTTABLEINNER(aLine[1] , cLinkA , .F.)
       cLinkB:=PUTTABLEINNER(aLine[3] , cLinkB , .F.)

       cTypeI:=IIF(Len(aLine)>4,aLine[5],"INNER")

       IF !EMPTY(cLinkA).OR.!EMPTY(cLinkB)
          cInner:=cInner+" "+cTypeI+" JOIN "+ALLTRIM(aLine[3])+" ON "+SQLJOIN(cLinkA,cLinkB) // +"="+cLinkB
       ELSE
          MensajeErr("Relaci�n no Encontrada "+aLine[1]+" "+aLine[3])
       ENDIF

     ENDIF
  NEXT I

  oGenRep:cSql:=cSql
  oGenRep:cInnerJoin:=cInner // Inner Join
  oGenRep:cSqlInnerJoin:=cInner // Inner Join


// ? oGenRep:cSqlInnerJoin

  EJECUTAR("REPGETORDER",oGenRep)

RETURN cSql

/*
// Coloca el Nombre de la Tabla
*/
FUNCTION PUTTABLEINNER(cTable,cCampos,lView)
   LOCAL aFields:=_VECTOR(cCampos,","),I,cExp:=""
 
   DEFAULT aFields:={}

   FOR I:=1 TO LEN(aFields)
      cExp:=cExp+IIF(I=1,"",",")+ALLTRIM(cTable)+"."+ALLTRIM(aFields[I])     
   NEXT I

RETURN cExp

FUNCTION SQLJOIN(cLinkA,cLinkB) // +"="+cLinkB
    LOCAL aLista1:=_VECTOR(cLinkA)
    LOCAL aLista2:=_VECTOR(cLinkB)
    LOCAL cJoin  :="",I:=0

    IF LEN(aLista1)<>LEN(aLista2)
       MensajeErr("Error en Relaci�n:"+CRLF+cLinkA+CRLF+cLinkB,"Revise la Relaci�n Entre las Tablas")
       RETURN ""
    ENDIF

    FOR I:=1 TO LEN(aLista1)
    
       cJoin:=cJoin + IIF(Empty(cJoin),""," AND ")+;
              aLista1[I]+"="+aLista2[I]

    NEXT I
   
RETURN cJoin
// EOF

