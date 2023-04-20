#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"

User Function INNCONFIG(aParm)

	Local aDirTemp 		:= {}//ParamIXB[1]
	Local cUserID		:= ""//ParamIXB[2]
	Local cCodGgle		:= ""//ParamIXB[3]

	aDirTemp := {	"\innweb\temp\",;					//Caminho temporaio onde o arquivo foi criado
					"/temp/",;							//Caminho temporario onde o arquivo foi criado para montar a URL de Download
					"\innweb\upload\",;					//Caminho de upload
					"\innweb\repositorio\",;				//caminho do repositorio de arquivos
					"C:\Totvs\Protheus\protheus_data\innweb\repositorio\",;		//Caminho completo do repositorio de arquivos (para MD5)
					"/repositorio/"}						//Caminho do repositorio para montar a URL de Download
								
Return( { aDirTemp , cCodGgle } )
