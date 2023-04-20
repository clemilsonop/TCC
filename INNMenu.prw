#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"

User Function INNMenu(aParm)

	Local aMenu 		:= ParamIXB[1]
	//Local cUserID 	:= ParamIXB[2]
	//Local cIdPgn 		:= ParamIXB[3]

	//Estoque custos
	aadd(aMenu,{'wIndex','Estoque/Custos','#','fas fa-cubes',.F.,{}})
	i := Len(aMenu)
	aadd(aMenu[i][6],{'wProd','u_wIndex.apw?x=wProd','Produto',.F.})
	aadd(aMenu[i][6],{'wSaldo','u_wIndex.apw?x=wSaldo','Saldos',.F.})
	//aadd(aMenu[i][6],{'wNFEntrada','u_wIndex.apw?x=wNFEntrada','NF Entrada',.F.})
	/*aadd(aMenu[i][6],{'wSA','u_wIndex.apw?x=wSA','Solicita Armazém',.F.})
				
	//PCP
	aadd(aMenu,{'wIndex','PCP','#','fas fa-industry',.F.,{}})
	i := Len(aMenu)	
	aadd(aMenu[i][6],{'wOP','u_wIndex.apw?x=wOP','Ordens Produção',.F.})
	
	//Compras	
	aadd(aMenu,{'wIndex','Compras','#','fas fa-calculator',.F.,{}})
	i := Len(aMenu)
	aadd(aMenu[i][6],{'wSC','u_wIndex.apw?x=wSC','Solicita Compra',.F.})
	aadd(aMenu[i][6],{'wPC','u_wIndex.apw?x=wPC','Pedido de Compra',.F.})
	aadd(aMenu[i][6],{'wFornece','u_wIndex.apw?x=wFornece','Fornecedores',.F.})*/
	
	//Comercial
	aadd(aMenu,{'wIndex','Faturamento','#','fas fa-shopping-cart',.F.,{}})
	i := Len(aMenu)
	aadd(aMenu[i][6],{'wCliente','u_wIndex.apw?x=wCliente','Clientes',.F.})
	//aadd(aMenu[i][6],{'wPV','u_wIndex.apw?x=wPV','Pedido de Venda',.F.})
	aadd(aMenu[i][6],{'wNFSaida','u_wIndex.apw?x=wNFSaida','NF Saida',.F.})
	/*
	//Financeiro
	aadd(aMenu,{'wFinanceiro','Financeiro','#','fas fa-money-bill-alt',.F.,{}})
	i := Len(aMenu)
	aadd(aMenu[i][6],{'wTitPag','u_wIndex.apw?x=wTitPag','Contas a Pagar',.F.})


	//Financeiro
	aadd(aMenu,{'wTI','Tec. Informação','#','fas fa-radiation',.F.,{}})
	i := Len(aMenu)
	aadd(aMenu[i][6],{'wINNLog','u_wIndex.apw?x=wINNLog','INN Log',.F.})
	aadd(aMenu[i][6],{'wINNMail','u_wIndex.apw?x=wINNMail','INN Mail',.F.})*/
										
Return(aMenu)
