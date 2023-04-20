#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"
#include "parmtype.ch"

CLASS INNWebBrowse FROM ClsINNWeb
	
	data oParent AS OBJECT READONLY
	data cTitulo
	data cTabela
	data nRec
	data cCampos
	data aCPOObr
	data aHead
	data aDados
	data lSX3
	data lCria
	data lDados
	data lErro

	METHOD New() Constructor
	METHOD Init()

	METHOD SetTabela(  )
	METHOD SetRec(  )
	METHOD SetHead( )
	METHOD SetDados(  )
	METHOD SetCampos(  )
	METHOD SetCPOObr(  )
	METHOD Execute(  )

ENDCLASS

METHOD New( xParent ) CLASS INNWebBrowse
	
    ::Init()
	::oParent := xParent

	::oParent:AddBody(Self)
	
Return Self

METHOD Init() CLASS INNWebBrowse

	::cTabela	:= ""
	::cTitulo	:= "Consulta padr�o"
	::nRec		:= 0
	::cCampos	:= ""
	::aCPOObr	:= {}
	::aHead		:= {}
	::aDados	:= {}
	::lSX3		:= .T.
	::lCria		:= .F.
	::lDados	:= .F.
	::lErro		:= .F.

Return

METHOD SetTabela( xTabela ) Class INNWebBrowse

	DbSelectArea("SX2")
	SX2->(DbSetOrder(1))
	if SX2->(DbSeek(xTabela))
		::cTitulo := Alltrim(SX2->X2_NOME)
		::cTabela := xTabela
	else
		::lErro	:= .T.
		Return(.F.)
	endif

Return(.T.)

METHOD SetRec( xRec ) Class INNWebBrowse

	dbSelectArea(::cTabela)
	(::cTabela)->(dbGoTo(xRec))  
	
	if xRec == (::cTabela)->(Recno())
		::lDados	:= .F.
		::nRec := (::cTabela)->(Recno())
	else
		::lErro	:= .T.
		Return(.F.)
	endif
Return

METHOD SetCampos( xCampos ) Class INNWebBrowse
	::cCampos := xCampos
Return

METHOD SetCPOObr( xCPOObr ) Class INNWebBrowse
	::aCPOObr := aClone(xCPOObr)
Return

METHOD SetHead( xHead ) Class INNWebBrowse
	::lSX3		:= .F.
	::lCria		:= .T.
	::lDados	:= .F.
	::aHead		:= aClone( xHead )
Return

METHOD SetDados( xDados ) Class INNWebBrowse
	::lSX3		:= .F.
	::lCria		:= .T.
	::lDados	:= .T.
	::aDados	:= aClone( xDados )
Return

METHOD Execute() Class INNWebBrowse

	Local cBody			:= ""
	Local aDicionario 	:= {{::cTabela + "X","Outros",{}}}
	Local aCampo		:= {}
	Local cPasta
	Local nPasta
	Local nY
	Local nX
	
	Private ALTERA   := .F.
	Private DELETA   := .F.
	Private INCLUI   := .F.
	Private VISUAL   := .T.
		
	if ::lErro
		::oParent:addCard("<h4>N�o foi possivel criar a consulta</h4>",::cTitulo)
		Return(.F.)
	endif

	if ::lSX3
	
		if ::lCria
			RegToMemory(::cTabela,.T.,.T.)
		else
			RegToMemory(::cTabela,.F.,.T.)			
		endif

		DbSelectArea("SXA")
		SXA->(DbSetOrder(1))
						
		DbSelectArea("SX3")
		SX3->(DbSetOrder(1))
		SX3->(dbSeek(::cTabela))
		
		WHILE !SX3->(EOF()) .and. ALLTRIM(SX3->X3_ARQUIVO) == ::cTabela 
	
			IF !( X3USO(SX3->X3_USADO)) .and. Empty(::cCampos)// .and. !(Alltrim(SX3->X3_CAMPO) $ ::aCPOObr)
				SX3->(dbSkip())
				Loop
			ENDIF
			
			if ("_FILIAL" $ Alltrim(SX3->X3_CAMPO) ) .and. Empty(::cCampos)
				SX3->(dbSkip())
				Loop
			ENDIF

			if !Empty(::cCampos) .and.  !(Alltrim(SX3->X3_CAMPO) $ ::cCampos)
				SX3->(dbSkip())
				Loop
			ENDIF
			
			cPasta := ::cTabela + iif(Empty(SX3->X3_FOLDER),"X",Alltrim(SX3->X3_FOLDER))
			nPasta := aScan(aDicionario,{|x|  Alltrim(x[1]) == cPasta })
			if nPasta < 1
				if SXA->(dbSeek(SX3->X3_ARQUIVO+SX3->X3_FOLDER))
					aadd(aDicionario,{cPasta,alltrim(SXA->XA_DESCRIC),{}})
				else
					aadd(aDicionario,{cPasta,"Outros",{}})
				endif				
				nPasta := Len(aDicionario)
			endif
			
			aCampo := {Alltrim(SX3->X3_CAMPO),Alltrim(SX3->X3_TITULO),nil,0,"T",SX3->X3_ORDEM}
			
			IF SX3->X3_TIPO ==  "D"
				aCampo[3] := dToc(M->&(SX3->X3_CAMPO))
			ELSEIF SX3->X3_TIPO ==  "N"
				aCampo[3] := Alltrim(TRANSFORM(M->&(SX3->X3_CAMPO),SX3->X3_PICTURE))
			ELSEIF SX3->X3_TIPO ==  "L"
				aCampo[3] := IIF(M->&(SX3->X3_CAMPO),"VERDADEIRO","FALSO")
			ELSEIF SX3->X3_TIPO ==  "C" .and. empty(SX3->X3_CBOX)
				aCampo[3] := Alltrim(M->&(SX3->X3_CAMPO))
			ELSEIF SX3->X3_TIPO ==  "C" .and. !empty(SX3->X3_CBOX)
				aCampo[3] := Alltrim(M->&(SX3->X3_CAMPO)) + fVOpcBox(M->&(SX3->X3_CAMPO),SX3->X3_CBOX,SX3->X3_CAMPO)
			ELSEIF SX3->X3_TIPO ==  "M"
				aCampo[3] := Alltrim(M->&(SX3->X3_CAMPO))
				aCampo[5] := "M"
				aCampo[6] := "ZZ"
			ELSE
				aCampo[3] := "DESPREPARADO PARA O TIPO: " + SX3->X3_TIPO
			ENDIF    
			
			aCampo[4] := cValToChar(Len(aCampo[3]))
			aCampo[4] := iif(Val(aCampo[4])<=100,aCampo[4],"100")
			aCampo[4] := iif(Val(aCampo[4])<=10,"10",aCampo[4])
			aadd(aDicionario[nPasta][3],aCampo)
						
			SX3->(dbSkip())
			
		ENDDO 
		
	elseif ::lDados

		//aDados[1] -> Conteudo/valor
		//aDados[1] -> Titulo
		//aDados[3] -> Tipo do campo

		aDicionario := {}
		aadd(aDicionario,{::cTabela + "X","Outros",{}})		
		nPasta := 1
		
		for nY := 1 To Len(::aDados)

			//aDados[1] -> Nome do campo
			//aDados[2] -> Titulo
			//aDados[3] -> Formato
			//aDados[4] -> Valor/Conteudo

			aCampo := {	::aDados[nY][1],;	//Nome do campo
						::aDados[nY][2],;	//Titulo
						nil,;				//Conteudo
						0,;					//Tamanho
						::aDados[nY][3],;	// Tipo
						strzero(len(aDicionario[nPasta][3]),2)}//Ordem

			IF ::aDados[nY][3] ==  "D"
				aCampo[3] := dToc(::aDados[nY][4])
			ELSEIF ::aDados[nY][3] ==  "N"
				aCampo[3] := Alltrim(TRANSFORM(::aDados[nY][4],"@E 99,999,999,999.999999"))
			ELSEIF ::aDados[nY][3] ==  "L"
				aCampo[3] := IIF(::aDados[nY][4],"VERDADEIRO","FALSO")
			ELSEIF ::aDados[nY][3] ==  "C"
				aCampo[3] := Alltrim(::aDados[nY][4])
			ELSEIF ::aDados[nY][3] ==  "M"
				aCampo[3] := LEFT(Alltrim(::aDados[nY][4]),100)
				aCampo[5] := "M"
				aCampo[6] := "ZZ"
			ELSE
				aCampo[3] := "DESPREPARADO PARA O TIPO: " + ::aDados[nY][3]
			ENDIF    
			
			aCampo[4] := cValToChar(Len(aCampo[3]))
			//aCampo[4] := iif(Val(aCampo[4])<=100,aCampo[4],"100")
			//aCampo[4] := iif(Val(aCampo[4])<=10,"10",aCampo[4])
			aadd(aDicionario[nPasta][3],aCampo)
			
		next nY

	else

		//aDados[1] -> Conteudo/valor
		//aDados[1] -> Titulo
		//aDados[3] -> Tipo do campo

		aDicionario := {}
		aadd(aDicionario,{::cTabela + "X","Outros",{}})		
		nPasta := 1
		
		for nY := 1 To Len(::aHead)
		
			aCampo := {::aHead[nY][1],::aHead[nY][2],nil,0,"T",strzero(len(aCampo),2)}

			IF ::aHead[nY][3] ==  "D"
				aCampo[3] := dToc((::cTabela)->&(::aHead[nY][1]))
			ELSEIF ::aHead[nY][3] ==  "N"
				aCampo[3] := Alltrim(TRANSFORM((::cTabela)->&(::aHead[nY][1]),"@E 99,999,999,999.999999"))
			ELSEIF ::aHead[nY][3] ==  "L"
				aCampo[3] := IIF((::cTabela)->&(::aHead[nY][1]),"VERDADEIRO","FALSO")
			ELSEIF ::aHead[nY][3] ==  "C"
				aCampo[3] := Alltrim((::cTabela)->&(::aHead[nY][1]))
			ELSEIF ::aHead[nY][3] ==  "M"
				aCampo[3] := LEFT(Alltrim((::cTabela)->&(::aHead[nY][1])),100)
				aCampo[5] := "M"
				aCampo[6] := "ZZ"
			ELSE
				aCampo[3] := "DESPREPARADO PARA O TIPO: " + ::aHead[nY][3]
			ENDIF    
			
			aCampo[4] := cValToChar(Len(aCampo[3]))
			aCampo[4] := iif(Val(aCampo[4])<=100,aCampo[4],"100")
			aCampo[4] := iif(Val(aCampo[4])<=10,"10",aCampo[4])
			aadd(aDicionario[nPasta][3],aCampo)
			
		next nY
	
	endif
			
	aDicionario := aSort(aDicionario,,, { |x, y| x[1] < y[1] })
		
	cBody := "<div class='card card-fluid'>" + CRLF
	cBody += "  <div class='card-body'>" + CRLF
	cBody += "    <h3 class='card-title'> "+::cTitulo+" </h3>" + CRLF
	if Len(aDicionario) > 1
		cBody += "<div class='card-header nav-scroller'>" + CRLF
		cBody += "<ul class='nav nav-tabs card-header-tabs'>" + CRLF
		for nY := 1 To Len(aDicionario)
			cBody += "<li class='nav-item'>" + CRLF
			cBody += "  <a class='nav-link"+iif(nY==1," active show","")+"' href='#"+aDicionario[nY][1]+"' data-toggle='tab'>"+aDicionario[nY][2]+"</a>" + CRLF
			cBody += "</li>" + CRLF
		next
		cBody += "</ul><!-- /.nav-tabs -->" + CRLF
		cBody += "</div><!-- /.card-header  nav-scroller -->" + CRLF
	endif

	cBody += "<div class='tab-content'>" + CRLF

	for nY := 1 To Len(aDicionario)

		cBody += "<div class='tab-pane fade"+iif(nY==1," active show","")+"' id='"+aDicionario[nY][1]+"' role='tabpanel'>" + CRLF
		cBody += "<div class=''>" + CRLF
		cBody += "<div class='card-body'>" + CRLF
		cBody += "<div class='form-row align-items-center'>" + CRLF

		aSort(aDicionario[nY][3],,, { |x, y| x[6] < y[6] })

		for nX := 1 To Len(aDicionario[nY][3])

			IF aDicionario[nY][3][nX][5] == "M"
				cBody += "<div class='col-sm-12'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				//cBody += "    <div class='form-label-group'>" + CRLF
				cBody += "      <label for='"+aDicionario[nY][3][nX][1]+"'>"+aDicionario[nY][3][nX][2]+"</label>" + CRLF
				cBody += "      <textarea class='form-control placeholder-shown' id='"+aDicionario[nY][3][nX][1]+"' name='"+aDicionario[nY][3][nX][1]+"' style='min-width: 400px;min-height: 100px;'>"+aDicionario[nY][3][nX][3]+"</textarea>" + CRLF
				//cBody += "    </div><!-- /form-label-group -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /col-sm-12 -->" + CRLF
				//cBody += "</div>" + CRLF
				//cBody += "</div>" + CRLF
			ELSE
				cBody += "<div class='col-sm-12 col-lg-"+::oParent:TamFild( { aDicionario[nY][3][nX][1] , aDicionario[nY][3][nX][2] , len(aDicionario[nY][3][nX][3]) , aDicionario[nY][3][nX][5] })+" my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF
				cBody += "      <input name='"+aDicionario[nY][3][nX][1]+"' type='text' class='form-control placeholder-shown' id='"+aDicionario[nY][3][nX][1]+"' value='"+aDicionario[nY][3][nX][3]+"'>" + CRLF
				cBody += "      <label>"+aDicionario[nY][3][nX][2]+"</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div>" + CRLF
			ENDIF

		next nX
		
		cBody += "</div><!-- /.form-row align-items-center -->" + CRLF
		cBody += "</div><!-- /.card-body -->" + CRLF
		cBody += "</div><!-- /.card card-fluid -->" + CRLF
		cBody += "</div><!-- /.tab-pane -->" + CRLF

	next nY

	cBody += "</div><!-- /.tab-content -->" + CRLF

	cBody += "</div><!-- card-body -->" + CRLF 
	cBody += "</div><!-- card card-fluid -->" + CRLF 
	//::oParent:AddBody(cBody)  		

Return(cBody)
