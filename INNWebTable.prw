#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"
#include "parmtype.ch"

CLASS INNWebTable FROM ClsINNWeb
	
	data oParent AS OBJECT READONLY
	data cTitulo
	data aHead
	data aCols
	data lCSV
	data aLinks
	data aForm
	data cNomArq
	data lSimples
	data lLinks
	data cLengthMenu
	data lLength

	METHOD New() Constructor
	METHOD Init()

	METHOD SetTitle(  )
    METHOD AddHead(  )
    METHOD AddCols(  )
    METHOD SetValue(  )
    METHOD SetLinks(  )
    METHOD SetLink(  )
	METHOD SetSimple(  )
	METHOD SetCSV(  )
	METHOD SetFile(  )
	METHOD Execute(  )
	METHOD lengthMenu(  )
	METHOD Setlength(  )

	METHOD xBrowse()

ENDCLASS

METHOD New( xParent ) CLASS INNWebTable
	
    //PARAMTYPE 0 VAR oParent AS OBJECT CLASS INNWebTable,ClsINNWeb

    ::Init()
	::oParent := xParent
            
    ::oParent:AddBody(Self)
	
Return Self

METHOD Init() CLASS INNWebTable

	::cTitulo		:= "Visualização em tela"
	::aHead			:= {}
	::aCols			:= {}
	::aLinks		:= {}
	::lCSV		:= .F.
	::aForm			:= {}
	::cNomArq		:= ""
	::lSimples		:= .F.
	::lLinks		:= .F.
	::cLengthMenu	:= "[25, 50, 100, -1], [ 25, 50, 100, 'All']"
	::lLength		:= .T.

Return

METHOD SetTitle( xTitulo ) Class INNWebTable
	::cTitulo := xTitulo
Return



METHOD AddHead( xHead ) Class INNWebTable
	//xHead[1] = Titulo
	//xHead[2] = Tipo
	//xHead[3] = Mascara
	//xHead[4] = link?
	if Len(xHead) < 4
		aadd(xHead,.F.)
	endif
	aadd(::aHead,aClone(xHead))
Return

METHOD AddCols( xCols ) Class INNWebTable
	aadd(::aCols,aClone(xCols))
	aadd(::aLinks,Array(len(::aHead)))
Return(Len(::aCols))

METHOD SetValue( xLinha , xCol , xValor ) Class INNWebTable
	Default xLinha := Len(::aCols)
	::aCols[xLinha][xCol] := xValor
Return

METHOD SetLinks( xLinks ) Class INNWebTable
	::aLinks := aClone(xLinks)
Return

METHOD SetLink( xLinha , xCol , xLink ) Class INNWebTable
	Default xLinha := Len(::aCols)
	::aLinks[xLinha][xCol] := xLink
Return

METHOD SetCSV(  ) Class INNWebTable
	::lCSV := .T.
Return

METHOD SetFile( xNomArq ) Class INNWebTable
	::cNomArq := xNomArq
Return

METHOD SetSimple(  ) Class INNWebTable
	::lSimples := .T.
Return

METHOD lengthMenu( xLengthMenu ) Class INNWebTable
	::cLengthMenu := xLengthMenu
Return

METHOD Setlength( xLength ) Class INNWebTable
	::lLength := xLength
Return

METHOD Execute() Class INNWebTable

	Local cBody	:= ""
	Local nY
	Local nLinha
	Local nCol
	Local aJSFoot
	Local cId
	Local cArq
	Local cArqD
	Local cLog
	Local nHandle
	Local cLinha
	Local cCampo
	Local cTipo
	Local aColsDef

	if ::lCSV

		if Empty(::cNomArq) 
			cId   := alltrim(CriaTrab( NIL, .F. ))
			cId   := "INN"+iif(!Empty(::oParent:cIdPgn),::oParent:cIdPgn,"")+dtos(date())+strtran(time(),":","")+"_"+substr(cId,3,len(cId))
			cArq  := ::oParent:aDirTemp[1] + cId + ".csv"
			cArqD := ::oParent:aDirTemp[2] + cId + ".csv"
		else
			cId   := alltrim(CriaTrab( NIL, .F. ))
			cId   := ::cNomArq+substr(cId,3,len(cId))
			cArq  := ::oParent:aDirTemp[1] + cId + ".csv"
			cArqD := ::oParent:aDirTemp[2] + cId + ".csv"		
		endif
		
		cLog := ""
		nHandle := FCreate(cArq)
		If nHandle == -1
			Self:addBody("<!-- ID: "+cId+" -->")
			Self:addBody("<!-- Arquivo: "+cArq+" -->")
			Self:addBody("<!-- URL: "+cArqD+" -->")
			cLog += 'Erro de abertura : FERROR ' + str(ferror(),4) + "<br>" + CRLF			
		else
			cLinha    := ""
			
			For nY := 1 To Len(::aHead)
				cLinha += Alltrim(::aHead[nY][1]) + ";"
			next
			FWrite(nHandle, cLinha + CRLF)
			
			For nLinha := 1 To Len(::aCols)
				cLinha := ""
				For nCol := 1 To Len(::aHead)
					cCampo := ::aCols[nLinha][nCol]
					cTipo  := ::aHead[nCol][2]//ValType(cCampo)
					if cTipo == "D"
						if Empty(cCampo)
							cCampo := ""
						else
							cCampo := dToc(cCampo)
						endif
					elseif cTipo == "N"
						cCampo := Alltrim(Transform(cCampo,::aHead[nCol][3]))
					elseif cTipo == "L"
						cCampo := iif(cCampo,'="Verdadeiro"','="Falso"')
					else
						if Empty(cCampo)
							cCampo := ""
						else
							cCampo := '"' + fTxtToCsv(cCampo) + '"'
						endif
					endif			
					cLinha += cCampo + ";"
				next nCol
				FWrite(nHandle, cLinha + CRLF) // Insere texto no arquivo  
			Next nLinha
			FClose(nHandle)
		endif  
		
		cBody += "<div class='card card-fluid'>" + CRLF
		cBody += "<div class='card-body'>" + CRLF	
		if !empty(cLog)
			cBody += cLog
		else
			cBody += "<h4>Arquivo gerado com sucesso!</h4>" + CRLF
			cBody += "<p>" + CRLF
			cBody += "ID: "+cId+"<br>Arquivo: "+cId+".csv" + CRLF
			cBody += "<br><br />" + CRLF
			cBody += "<button type='button' class='btn btn-primary' onClick="+char(34)+"location.href='"+cArqD+"'"+char(34)+">Baixar</button>" + CRLF
			cBody += "</p>" + CRLF		
		endif
		cBody += "</div><!-- /card-body -->" + CRLF
		cBody += "</div><!-- /card card-fluid -->" + CRLF

	else
	
		::lLinks := iif( Len(::aCols) == Len(::aLinks) , .T. , .F. )
		cId   := alltrim(CriaTrab( NIL, .F. ))
		if Empty(::cNomArq) 
			cId   := "INN"+iif(!Empty(::oParent:cIdPgn),::oParent:cIdPgn,"")+dtos(date())+strtran(time(),":","")+"_"+substr(cId,3,len(cId))
		else
			cId   := ::cNomArq+substr(cId,3,len(cId))
		endif
		cArq  := ::oParent:aDirTemp[1] + cId + ".json"
		cArqD := ::oParent:aDirTemp[2] + cId + ".json"

		cBody += "<div class='card card-fluid'>" + CRLF
		cBody += "  <div class='card-body'>" + CRLF
		cBody += "    <h3 class='card-title'> "+::cTitulo+" </h3>" + CRLF
		cBody += "	<table id='"+cId+"' class='table table-striped table-bordered table-hover'>" + CRLF
		cBody += "	  <thead>" + CRLF
		cBody += "		<tr>" + CRLF
		For nY := 1 To Len(::aHead)
			cBody += "		  <th> "+Alltrim(::aHead[nY][1])+" </th>" + CRLF
		next
		cBody += "		</tr>" + CRLF
		cBody += "	  </thead>" + CRLF
		cBody += "	</table><!-- /.table -->" + CRLF
		cBody += "  </div><!-- /.card-body -->" + CRLF
		cBody += "</div><!-- /.card -->" + CRLF

		aColsDef := {}
		aJSFoot := {}
		aadd(aJSFoot,"$('#"+cId+"').DataTable({")
		if ::lSimples
			aadd(aJSFoot,"dom: "+chr(34)+"<'row'<'col-sm-12 col-md-6'><'col-sm-12 col-md-6 text-right'>>\n<'table-responsive'tr>\n<'row align-items-center'<'col-sm-12 col-md-5'><'col-sm-12 col-md-7 d-flex justify-content-end'>>"+chr(34)+",")
			aadd(aJSFoot,"paging: false,")
			aadd(aJSFoot,"ordering: false,")
			aadd(aJSFoot,"searching: false,")
			aadd(aJSFoot,"buttons: [{extend: 'csv',text: 'CSV',fieldSeparator: ';'}, 'excel', 'print'],")
		else
			if ::lLength
				aadd(aJSFoot,"dom: "+chr(34)+"<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6 text-right'B>>\n<'table-responsive'tr>\n<'row align-items-center'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 d-flex justify-content-end'p>>"+chr(34)+",")
			else
				aadd(aJSFoot,"dom: "+chr(34)+"<'row'<'col-sm-12 col-md-6'i><'col-sm-12 col-md-6 text-right'B>>\n<'table-responsive'tr>\n<'row align-items-center'<'col-sm-12 col-md-5'><'col-sm-12 col-md-7 d-flex justify-content-end'>>"+chr(34)+",")
			endif
			aadd(aJSFoot,"lengthMenu: ["+::cLengthMenu+"],")
			aadd(aJSFoot,"order: [0, 'asc'],")
			aadd(aJSFoot,"buttons: [{extend: 'csv',text: 'CSV',fieldSeparator: ';'}, 'excel', 'print'],")//pageOrientation: 'landscape',
		endif
		aadd(aJSFoot,"language: {'url': 'vendor/datatables.net-4/pt-br.json'},")
		aadd(aJSFoot,"ajax: '"+cArqD+"',")
		aadd(aJSFoot,"columns: [")
		For nY := 1 To Len(::aHead)
			cLinha := iif(nY>1,",","")
			cCpoHed := "FIELD"+StrZero(nY,3)
			Do Case
				Case ::aHead[nY][4]
					cLinha += "{ data: {_:'"+cCpoHed+".display'}}"
					aadd(aColsDef,	"{ targets: "+cValtoChar(nY-1)+",render: function ( data, type, row ) {return '<a href="+chr(34)+"'+row."+cCpoHed+".url+'"+chr(34)+" target="+chr(34)+"'+row."+cCpoHed+".target+'"+chr(34)+">'+data+'</a>';}}")
				Case ::aHead[nY][2] == "D" 
					cLinha += "{ data: {_:'"+cCpoHed+".display',sort: '"+cCpoHed+".url'}}"
					aadd(aColsDef,"{className: 'text-center', targets: "+cValtoChar(nY-1)+"}")
				Case ::aHead[nY][2] == "N"
					cLinha += "{ data: {_:'"+cCpoHed+".display',sort: '"+cCpoHed+".valor'}}"
					aadd(aColsDef,"{className: 'text-right', targets: "+cValtoChar(nY-1)+"}")
				OtherWise
					cLinha += "{ data: '"+cCpoHed+"' }"
			End Case
			aadd(aJSFoot,cLinha)
		next
		aadd(aJSFoot,"],")
		aadd(aJSFoot,"columnDefs: [")
		For nY := 1 To Len(aColsDef)
			aadd(aJSFoot,iif(nY>1,",","")+aColsDef[nY])
		next 
		aadd(aJSFoot,"]")
		aadd(aJSFoot,"});")
				
		::oParent:addJSFoot(aJSFoot)

		nHandle := FCreate(cArq)

		If nHandle == -1
			Self:addBody("<!-- ID: "+cId+" -->")
			Self:addBody("<!-- Arquivo: "+cArq+" -->")
			cLog += 'Erro de abertura : FERROR ' + str(ferror(),4) + "<br>" + CRLF			
		else
			
			FWrite(nHandle, '{"data": [')
			
			For nLinha := 1 To Len(::aCols)
				cLinha := ""
				cLinha += iif(nLinha>1,",","")
				cLinha += "{"
				For nCol := 1 To Len(::aHead)

					cCpoHed := "FIELD"+StrZero(nCol,3)
					cCampo  := ::aCols[nLinha][nCol]
					cTipo   := ::aHead[nCol][2]
					lLink	:= .F.

					if ::lLinks
						if ValType(::aLinks[nLinha]) == "A"
							if ValType(::aLinks[nLinha][nCol]) == "A"
								lLink	:= .T.
								clink   := iif(Len(::aLinks)==0,"",::aLinks[nLinha][nCol][1])
								cTarget := iif(Len(::aLinks)==0,"",::aLinks[nLinha][nCol][2])
							elseif ValType(::aLinks[nLinha][nCol]) == "C"
								lLink	:= .T.
								clink   := ::aLinks[nLinha][nCol]
								cTarget := ""
							endif
						endif
					endif

//conout(cCpoHed)
//conout(lLink)
//conout(cTipo)

					Do Case

						Case lLink .and. cTipo == "D" .and. Empty(cCampo)
							cCampo := '"'+cCpoHed+'": {"display": "/  /","url": "'+clink+'","target": "'+cTarget+'"}'
						Case lLink .and. cTipo == "D" .and. !Empty(cCampo)
							cCampo := '"'+cCpoHed+'": {"display": "'+dToc(cCampo)+'","url": "'+clink+'","target": "'+cTarget+'"}'
						Case lLink .and. cTipo == "N"
							cCampo := '"'+cCpoHed+'": {"display": "'+Alltrim(Transform(cCampo,::aHead[nCol][3]))+'","url": "'+clink+'","target": "'+cTarget+'"}'
						Case lLink .and. cTipo == "L"
							cCampo := '"'+cCpoHed+'": {"display": "'+iif(cCampo,'"Verdadeiro"','"Falso"')+'","url": "'+clink+'","target": "'+cTarget+'"}'
						Case lLink .and. cTipo == "C"
							cCampo := '"'+cCpoHed+'": {"display": "'+fTxtToCsv(cCampo)+'","url": "'+clink+'","target": "'+cTarget+'"}'


						Case cTipo == "D" .and. Empty(cCampo)
							cCampo := '"'+cCpoHed+'": {"display": "","timestamp": "0"}'
						Case cTipo == "D" .and. !Empty(cCampo)
							cCampo := '"'+cCpoHed+'": {"display": "'+dToc(cCampo)+'","timestamp": "'+FWTimeStamp(4,cCampo,"00:00:00")+'"}'
						Case cTipo == "N"
							cCampo := '"'+cCpoHed+'": {"display":"'+Alltrim(Transform(cCampo,::aHead[nCol][3]))+'","valor": "'+cValToChar(cCampo)+'"}
						Case cTipo == "L"
							cCampo := '"'+cCpoHed+'": '+iif(cCampo,'"Verdadeiro"','"Falso"')

						OtherWise
							cCampo := '"'+cCpoHed+'": "'+fTxtToCsv(cCampo)+'"'

					End Case

					cLinha += iif(nCol>1,",","")
					cLinha += cCampo

				next nCol
				cLinha += "}"
				FWrite(nHandle, cLinha + CRLF) // Insere texto no arquivo  
			Next nLinha
			FWrite(nHandle, "]}")
			FClose(nHandle)

		endif  

	endif

Return(cBody)




// --------------------------------------------------------------------------
METHOD xBrowse(cTabela2,nIndex,bRegra,cCampos) Class INNWebTable

	Local aCampo		:= {}
	Local nY
	
	Local aArea		:= GetArea()
	Local aAreaEsp	:= (cTabela2)->(GetArea())
	
	Private ALTERA   := .F.
	Private DELETA   := .F.
	Private INCLUI   := .F.
	Private VISUAL   := .T.
	
	Default cCampos := ""
				
	aCampo := {}
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(dbSeek(cTabela2))
	
	WHILE !SX3->(EOF()) .and. ALLTRIM(SX3->X3_ARQUIVO) == cTabela2 

		IF ( X3USO(SX3->X3_USADO) .or.  "_FILIAL" $ Alltrim(SX3->X3_CAMPO) )  .or. Alltrim(SX3->X3_CAMPO) $ cCampos
						
			aadd(aCampo ,{Alltrim(SX3->X3_CAMPO),Alltrim(SX3->X3_TITULO),SX3->X3_TIPO,SX3->X3_PICTURE,SX3->X3_CBOX})
			
		ENDIF
					
		SX3->(dbSkip())
		
	ENDDO 				

	for nY := 1 To len(aCampo)
	
		Self:AddHead({aCampo[nY,2],aCampo[nY,3],aCampo[nY,4]})
	
	next nY
	
	DbSelectArea(cTabela2)
	(cTabela2)->(DBClearFilter())
	(cTabela2)->(DBSetFilter( { || &bRegra } , bRegra ))
	(cTabela2)->(dbSetOrder(nIndex)) 
	(cTabela2)->(dbGoTop()) 
		
	WHILE !( (cTabela2)->(EOF()) )// .and. {|| bRegra }
	
		RegToMemory(cTabela2,.F.,.T.)
		aLinha := {}
		
		for nY := 1 To len(aCampo)
		
			IF aCampo[nY,3] ==  "D" // Data
				aadd(aLinha, M->&(aCampo[nY,1]) )
				
			ELSEIF aCampo[nY,3] ==  "N" // Numerico
				aadd(aLinha, M->&(aCampo[nY,1]) )
				
			ELSEIF aCampo[nY,3] ==  "L" // Logico
				aadd(aLinha, M->&(aCampo[nY,1]) )
				
			ELSEIF aCampo[nY,3] ==  "C" .and. Empty(aCampo[nY,5]) // Caracter
				aadd(aLinha, Alltrim(M->&(aCampo[nY,1])) )
				
			ELSEIF aCampo[nY,3] ==  "C" .and. !Empty(aCampo[nY,5]) // Caracter
				aadd(aLinha, Alltrim(M->&(aCampo[nY,1])) + fVOpcBox(M->&(aCampo[nY,1]),"",aCampo[nY,1]) )
				
			ELSEIF aCampo[nY,3] ==  "M" // Memo
				aadd(aLinha, LEFT(Alltrim(M->&(aCampo[nY,1])),100) )
				
			ELSE
			
				aadd(aLinha, "DESPREPARADO PARA O TIPO: " + aCampo[nY,3] )
				
			ENDIF 
		
		next nY
		
		Self:AddCols(aClone(aLinha))
	
		(cTabela2)->(dbSkip())
		
	ENDDO 
	
	Self:SetTitle( cTabela2 + " - " + Alltrim(POSICIONE("SX2",1,cTabela2,"X2_NOME")) )
	
	(cTabela2)->(DBClearFilter())
	(cTabela2)->(RestArea(aAreaEsp))
	RestArea(aArea)
		
Return




Static Function fTxtToCsv(cTexto)
	cTexto := Alltrim(cTexto)
	cTexto := StrTran(cTexto,chr(129),"")
	cTexto := StrTran(cTexto,chr(141),"")
	cTexto := StrTran(cTexto,chr(143),"")
	cTexto := StrTran(cTexto,chr(144),"")
	cTexto := StrTran(cTexto,chr(157),"")
	cTexto := StrTran(cTexto,chr(9),"")
	cTexto := StrTran(cTexto,";","")	
	cTexto := StrTran(cTexto,'"',"")
	cTexto := StrTran(cTexto,CRLF,"<br/>")
	cTexto := EncodeUtf8(cTexto)
Return(cTexto)
