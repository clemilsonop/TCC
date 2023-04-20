#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"
#include "parmtype.ch"

CLASS INNWebParam FROM ClsINNWeb
	
	data oParent AS OBJECT READONLY
	data aParm
	data cTitulo
	data cTexto
	data cLbButon
	data lGet

	METHOD New() Constructor
	METHOD Init()

	METHOD SetTitle(  )
	METHOD SetParm(  )


	METHOD SetTexto(  )
	METHOD SetTxtButton(  )
	METHOD SetMethodGet(  )
	METHOD SetMethodPost(  )

	METHOD Execute(  )

	METHOD addData()
	METHOD addNum()
	METHOD addMonetary()
	METHOD addCombo()
	METHOD addComboMultiple()
	METHOD addHidden()
	METHOD addMemo()
	METHOD addFILIAL()
	METHOD addText()
	METHOD AddParm(  )

ENDCLASS

METHOD SetTitle( xTitulo ) CLASS INNWebParam
	::cTitulo := xTitulo
Return

METHOD SetParm( xParm ) CLASS INNWebParam
	::aParm := xParm
Return

METHOD SetTexto( xTexto ) CLASS INNWebParam
	::cTexto := xTexto
Return

METHOD SetTxtButton( xLbButon ) CLASS INNWebParam
	::cLbButon := xLbButon
Return

METHOD SetMethodGet(  ) CLASS INNWebParam
	::lGet := .T.
Return

METHOD SetMethodPost(  ) CLASS INNWebParam
	::lGet := .F.
Return

METHOD New( xParent ) CLASS INNWebParam
	
    //PARAMTYPE 0 VAR oParent AS OBJECT CLASS INNWebParam,ClsINNWeb

    ::Init()
	::oParent := xParent
            
    //oParent:AddItem(Self)	

	::oParent:AddBody(Self)
	
Return Self

METHOD Init() CLASS INNWebParam

	::aParm			:= {}
	::cTitulo		:= "Parâmetros"
	::cTexto		:= ""
	::cLbButon		:= "Pesquisar"
	::lGet			:= .T.

Return

METHOD Execute() Class INNWebParam

	Local cBody := ""
	Local nY	:= 0
	Local nX 	:= 0
	Local aSM0  := {}
	Local aTemp := FWLoadSM0()
	
	For nX := 1 To Len(aTemp)
		if .T.//HttpSession->WsEmp == aTemp[nX][1]
			aadd(aSM0,aClone(aTemp[nX]))
		endif
	Next nX
	
	aadd(::aParm ,{'x','x',0,'H',::oParent:cPagina,.F.})
			
	cBody += "<div class='card card-fluid'>" + CRLF
	cBody += "<div class='card-body'>" + CRLF
	cBody += "<h3 class='card-title'> "+::cTitulo+" </h3>" + CRLF
	if !Empty(::cTexto)
		cBody += "<p>"+::cTexto+"</p>" + CRLF
	endif
	cBody += "<form class='' method='"+iif(::lGet,"get","post")+"' enctype='application/x-www-form-urlencoded' name='parametro' id='parametro'>" + CRLF	
	cBody += "<div class='form-row align-items-center'>" + CRLF

	for nY := 1 To Len(::aParm)

		Do case

			Case ::aParm[nY][4] == "D" //Data
				::aParm[nY][5] := iif(empty(::aParm[nY][5]),"",dToc(::aParm[nY][5]))
				cBody += "<div class='col-sm-12 col-lg-"+::oParent:TamFild(::aParm[nY])+" my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF
				cBody += "      <input name='"+::aParm[nY][1]+"' "
				cBody += "             type='text' "
				cBody += "             class='form-control' "
				cBody += "             id='"+::aParm[nY][1]+"' "
				cBody += "             value='"+::aParm[nY][5]+"' "
				cBody += "             maxlength='10' "
				cBody += "             autocomplete='off' "
				IF ::aParm[nY][6]
					cBody += "         required "
				endif
				cBody += ">" + CRLF
				cBody += "      <label>"+::aParm[nY][2]+"</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /form-label-group -->" + CRLF
				::oParent:AddLoad({ "$('#"+::aParm[nY][1]+"').datepicker({format: 'dd/mm/yyyy',todayBtn: 'linked',language: 'pt-BR',autoclose: true,toggleActive: true});" })			
				::oParent:AddLoad({ "$('#"+::aParm[nY][1]+"').mask('99/99/9999');" })
			
			Case ::aParm[nY][4] == "N" //Numerico
				aTemp := aClone(::aParm[nY])
				aTemp[3] += 20
				cPic := "@E 999,999,999,999."+Replicate("9",::aParm[nY][3])
				cBody += "<div class='col-sm-12 col-lg-"+::oParent:TamFild(aTemp)+" my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF
				cBody += "			    <input name='"+::aParm[nY][1]+"' "
				cBody += "                     type='text' "
				cBody += "                     class='form-control' "
				cBody += "                     id='"+::aParm[nY][1]+"' "
				cBody += "                     value='"+Alltrim(Transform(::aParm[nY][5],cPic))+"' "
				IF nY == 1
					cBody += "                     autofocus='' "
				endif
				IF ::aParm[nY][6]
					cBody += "                     required "
				endif
				cBody += "                     >" + CRLF
				cBody += "      <label>"+::aParm[nY][2]+"</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /form-label-group -->" + CRLF
				::oParent:AddLoad({ "$('#"+::aParm[nY][1]+"').maskMoney({prefix:'', allowNegative: true, thousands:'.', decimal:',', affixesStay: false,precision: "+cValtochar(::aParm[nY][3])+"});" })

			
			Case ::aParm[nY][4] == "MN" //Monetario
				cBody += "<div class='col-sm-12 col-lg-"+::oParent:TamFild(::aParm[nY])+" my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF
				cBody += "			    <input name='"+::aParm[nY][1]+"' "
				cBody += "                     type='text' "
				cBody += "                     class='form-control' "
				cBody += "                     id='"+::aParm[nY][1]+"' "
				cBody += "                     value='"+Alltrim(Transform(::aParm[nY][5],"@E 999,999,999,999.99"))+"' "
				cBody += "                     placeholder='0,00' "
				cBody += "                     autocomplete='off' "
				IF nY == 1
					cBody += "                     autofocus='' "
				endif
				IF ::aParm[nY][6]
					cBody += "                     required "
				endif
				cBody += "                     >" + CRLF
				cBody += "      <label>"+::aParm[nY][2]+"</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /form-label-group -->" + CRLF
				::oParent:AddLoad({ "$('#"+::aParm[nY][1]+"').maskMoney({prefix:'R$ ', allowNegative: true, thousands:'.', decimal:',', affixesStay: false});" })
			
			Case ::aParm[nY][4] == "C"//Combo ou select
				cBody += "<div class='col-sm-12 col-lg-"+::oParent:TamFild(::aParm[nY])+" my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF
				cBody += "					<select id='"+Alltrim(::aParm[nY][1])+"' name='"+Alltrim(::aParm[nY][1])+"' class='custom-select' " 
				IF ::aParm[nY][6]
					cBody += " required "
				endif
				IF nY == 1
					cBody += " autofocus='' "
				endif
				cBody += " >" + CRLF
				for nX := 1 To Len(::aParm[nY][7])
					cBody += "						<option value='"+Alltrim(::aParm[nY][7][nX][1])+"'>"+Alltrim(::aParm[nY][7][nX][2])+"</option>" + CRLF
				next nX
				cBody += "		         </select>" + CRLF
				cBody += "      <label>"+::aParm[nY][2]+"</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /form-label-group -->" + CRLF
				::oParent:AddLoad({"$('#"+::aParm[nY][1]+"').val('"+::aParm[nY][5]+"');"})
			
			Case ::aParm[nY][4] == "CM"//Combo ou select multipla escolha
				cBody += "<div class='col-sm-12 col-lg-"+::oParent:TamFild(::aParm[nY])+" my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF
				cBody += "      <select id='"+Alltrim(::aParm[nY][1])+"' name='"+Alltrim(::aParm[nY][1])+"' size='2' class='form-select custom-select' multiple='multiple' "//multiple='multiple' style='min-width: 100px;' " 
				IF ::aParm[nY][6]
					cBody += " required "
				endif
				IF nY == 1
					cBody += " autofocus='' "
				endif
				cBody += " >" + CRLF
				for nX := 1 To Len(::aParm[nY][7])
					cBody += " <option value='"+Alltrim(::aParm[nY][7][nX][1])+"'>"+Alltrim(::aParm[nY][7][nX][2])+"</option>" + CRLF
				next nX
				cBody += "      </select>" + CRLF
				cBody += "      <label>"+::aParm[nY][2]+"</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /form-label-group -->" + CRLF

				aValSelect := StrTokArr(::aParm[nY][5],",")
				cValSelect := ""
				for nX := 1 To Len(aValSelect)
					cValSelect += iif(Empty(cValSelect),"",",")
					cValSelect += "'"+Alltrim(aValSelect[nX])+"'"
				next nX	
				
				::oParent:AddLoad({"$('#"+Alltrim(::aParm[nY][1])+"').val(["+cValSelect+"]).trigger('change');"})
		
			Case ::aParm[nY][4] == "H" //Hidden (Escondido)
				cBody += "			    <input name='"+::aParm[nY][1]+"' "
				cBody += "                     type='hidden' "
				cBody += "                     id='"+::aParm[nY][1]+"' "
				cBody += "                     value='"+::aParm[nY][5]+"'>" + CRLF
			
			Case ::aParm[nY][4] == "M"//Campo memo
				cBody += "<div class='col-sm-12 col-lg-"+::oParent:TamFild(::aParm[nY])+" my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF		
				cBody += "			    <textarea style='width:100%; min-height: 500px;' "
				cBody += "                     name='"+::aParm[nY][1]+"' "			
				cBody += "                     class='form-control' "
				cBody += "                     id='"+::aParm[nY][1]+"' "
				IF nY == 1
					cBody += "                     autofocus='' "
				endif
				IF ::aParm[nY][6]
					cBody += "                     required "
				endif
				IF ::aParm[nY][4] == "TB"
					cBody += "                     disabled "
				endif
				cBody += "                     >"+::aParm[nY][5]+"</textarea>" + CRLF
				cBody += "      <label>"+::aParm[nY][2]+"</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /form-label-group -->" + CRLF		
			
			Case ::aParm[nY][4] == "FILIAL"//Exibe um combo para escolha das filais
				::aParm[nY][1] := "FilsCalc"
				::aParm[nY][2] := "Filial"
				::aParm[nY][3] := 20
				cBody += "<div class='col-sm-12 col-lg-"+::oParent:TamFild(::aParm[nY])+" my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF
				cBody += "	    <select id='FilsCalc' name='FilsCalc' size='2' class='form-select custom-select' required multiple "// multiple='multiple' style='min-width: 100px;' " 
				IF nY == 1
					cBody += " autofocus='' "
				endif
				cBody += " > "
				for nX := 1 To Len(aSM0)
					cBody += "<option value='"+Alltrim(aSM0[nX][2])+"'>"+Alltrim(aSM0[nX][7])+"</option>" + CRLF
				next nX
				cBody += "		         </select>" + CRLF
				cBody += "      <label>Filial</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /form-label-group -->" + CRLF
				if ::aParm[nY][5] .and. Empty(::oParent:cFilsCalc)// .and. Empty(cformID)
					for nX := 1 To Len(aSM0)
						::oParent:cFilsCalc += iif(Empty(::oParent:cFilsCalc),"",",")
						::oParent:cFilsCalc += "'"+Alltrim(aSM0[nX][2])+"'"
					next nX				
				endif
				::oParent:AddLoad({"$('#FilsCalc').val(["+::oParent:cFilsCalc+"]).trigger('change');"})

			OtherWise //Texto
				cBody += "<div class='col-sm-12 col-lg-"+::oParent:TamFild(::aParm[nY])+" my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF
				cBody += "			    <input name='"+::aParm[nY][1]+"' "
				cBody +=                      "type='text' "
				cBody +=                      "class='form-control' "
				cBody +=                      "id='"+::aParm[nY][1]+"' "
				cBody +=                      "value='"+::aParm[nY][5]+"' "
				cBody +=                      "maxlength='"+cValToChar(::aParm[nY][3])+"' "
				IF nY == 1
					cBody +=                  "autofocus='' "
				endif
				IF ::aParm[nY][6]
					cBody +=                  "required "
				endif
				IF ::aParm[nY][4] == "TB"
					cBody +=                  "disabled "
				endif
				cBody +=                      ">" + CRLF
				cBody += "      <label>"+::aParm[nY][2]+"</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /form-label-group -->" + CRLF

		end

	next nY

	cBody += "			  </div><!-- /form-row align-items-center -->" + CRLF

	cBody += "    <div class='form-actions'>" + CRLF
    cBody += "      <button class='btn btn-primary' type='submit'>"+::cLbButon+"</button>" + CRLF
	cBody += "    </div><!-- /.form-actions -->" + CRLF
	cBody += "    </form>" + CRLF
	cBody += "  </div><!-- /card-body -->" + CRLF
	cBody += "</div><!-- /card card-fluid -->" + CRLF
	
	//::oParent:AddBody(cBody)  

Return(cBody)

METHOD addData(xParm) Class INNWebParam

	Local aItemParm := {"",;	 	//Campo
						"",;	 	//Titulo do Campo
						0,; 		//Tamanho
						'D',; 		//Tipo do Campo
						"",; 		//Conteudo 
						.F.} 		//Obrigatorio? (required)

	aItemParm[1] := xParm[1] //01 Campo
	aItemParm[2] := xParm[2] //02 Titulo do Campo
	if ValType (xParm[3] ) != "D"
		aItemParm[5] := cTod("") //04 Conteudo
	else
		aItemParm[5] := xParm[3] //04 Conteudo
	endif
	aItemParm[6] := xParm[4] //05 Obrigatorio? (required)

	aadd(::aParm,aClone(aItemParm))

Return(Len(::aParm))

METHOD addNum(xParm) Class INNWebParam
	aadd(::aParm,aClone(xParm))
Return(Len(::aParm))

METHOD addMonetary(xParm) Class INNWebParam
	aadd(::aParm,aClone(xParm))
Return(Len(::aParm))

METHOD addCombo(xParm) Class INNWebParam
	Local aItemParm := {"",;	 	//Campo
						"",;	 	//Titulo do Campo
						0,; 		//Tamanho
						'C',; 		//Tipo do Campo
						"",; 		//Conteudo 
						.F.,; 		//Obrigatorio? (required)
						{}}			//Itens da array

	aItemParm[1] := xParm[1] //01 Campo
	aItemParm[2] := xParm[2] //02 Titulo do Campo
	aItemParm[5] := xParm[3] //04 Conteudo 
	aItemParm[6] := xParm[5] //05 Obrigatorio? (required)
	aItemParm[7] := xParm[4] //Itens da array

	aadd(::aParm,aClone(aItemParm))

Return(Len(::aParm))

METHOD addComboMultiple(xParm) Class INNWebParam
	aadd(::aParm,aClone(xParm))
Return(Len(::aParm))

METHOD addHidden(xParm) Class INNWebParam
	Local aItemParm := {"",;	 	//Campo
						"",;	 	//Titulo do Campo
						0,; 		//Tamanho
						'H',; 		//Tipo do Campo
						"",; 		//Conteudo 
						.F.} 		//Obrigatorio? (required)

	aItemParm[1] := xParm[1] //01 Campo
	aItemParm[5] := xParm[2] //04 Conteudo 

	aadd(::aParm,aClone(aItemParm))
Return(Len(::aParm))

METHOD addMemo(xParm) Class INNWebParam
	aadd(::aParm,aClone(xParm))
Return(Len(::aParm))

METHOD addFILIAL(xParm) Class INNWebParam
	aadd(::aParm,aClone(xParm))
Return(Len(::aParm))

METHOD addText(xParm) Class INNWebParam

	Local aItemParm := {"",;	 	//Campo
						"",;	 	//Titulo do Campo
						0,; 		//Tamanho
						'T',; 		//Tipo do Campo
						"",; 		//Conteudo 
						.F.} 		//Obrigatorio? (required)

	aItemParm[1] := xParm[1] //01 Campo
	aItemParm[2] := xParm[2] //02 Titulo do Campo
	aItemParm[3] := xParm[3] //03 Tamanho
	aItemParm[5] := xParm[4] //04 Conteudo 
	aItemParm[6] := xParm[5] //05 Obrigatorio? (required)

	aadd(::aParm,aClone(aItemParm))

Return(Len(::aParm))

METHOD AddParm(xParm) Class INNWebParam
	aadd(::aParm,aClone(xParm))
Return(Len(::aParm))
