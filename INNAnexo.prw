#include "TOTVS.CH"
  
User Function INNAnexo(cTipo,cDocumento)

	Local __oDlgAnexo	:= nil
	Local oTIBrowser 	:= nil
	Local cToken		:= Alltrim(GetMV("IN_TOKEN"))+RetCodUsr()
	Local cURL 			:= Alltrim(GetMV("IN_SRVURL")) + "u_wIndex.apw?x=wExplorer&Tipo="+cTipo+"&Documento="+cDocumento+"&Simples=S&Token="+cToken
	
	Local aObjects
	Local aSize
	Local aInfo
	Local aPosObj
	
	aObjects := {}
	aSize    := MsAdvSize(.F.)
	aSize[3] := aSize[3]*0.70//horizontal
	aSize[5] := aSize[5]*0.70//horizontal
	aSize[4] := aSize[4]*0.70//vertival
	aSize[6] := aSize[6]*0.70//vertival
	aInfo    := { aSize[ 1 ] , aSize[ 2 ] , aSize[ 3 ] , aSize[ 4 ] , 0 , 0 }
	AAdd( aObjects, { 100, 100, .T. , .T. , } )
	aPosObj  := MsObjSize( aInfo, aObjects )
	
	__oDlgAnexo      := MSDialog():New( aSize[7],aSize[1],aSize[6],aSize[5],"Anexos",,,.F.,,,,,,.T.,,,.T. )
	oTIBrowser := TIBrowser():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,4],aPosObj[1,3], cURL, __oDlgAnexo )
	__oDlgAnexo:Activate(,,,.T.)
  
Return