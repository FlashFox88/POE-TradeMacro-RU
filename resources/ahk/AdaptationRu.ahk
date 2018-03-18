/*

��������������� ������� ��� ������� ���������


*/



; ������������ ������� �������� ����� � �� ���������� ��������
; ��������� ������� �������� ����� � ��������� ���������
ConvertRuModToEn(_item)
{
	For k, imod in _item.mods {
		
		_item.mods[k].name_ru := _item.mods[k].name
		_item.mods[k].name := Ru_En_Stats_Value(_item.mods[k].name)
		
		; ���������� ��������������� ������������ �������� ����, 
		; ��� ����� ��� ����� � �������, �������� "����� 1 ������" 
		; - ��� ����� ����� � ����� ������ ���� ������������ ������� �������� � ��������� ����������
		_item.mods[k].name_orig_en := Ru_En_Stats_Value(_item.mods[k].name_orig)
		
		; ���� ��� �� ��� ��������������
		If (_item.mods[k].name = _item.mods[k].name_ru) {		
			; � ������� ������������ �������� ����� ��� ����� � ������, ������� ���� �� ������������, �� ����������� �� ����
			RegExMatch(_item.mods[k].name, "(.*)([+]#)(.*)", mod_name)			
			modRu := mod_name1 "#" mod_name3
			modEn := Ru_En_Stats_Value(modRu)
			; � ��������� ����� ��������� ����������� ��������
			_item.mods[k].name := StrReplace(modEn, "#", "+#")
		}
	}
;console_log(_item, "_item")
	Return _item
}


; ��������������� ��� ����� ������ ����
ConvertRuOneModToEn(smod)
{
	; � ������� ������������ �������� ����� ��� ������ � ������, ������� ���� �� ������������, �� ����������� �� ����		
	If (RegExMatch(smod, "^([+])")) {
		RegExMatch(smod, "^([+])(.*)", mod_name)
		; � ��������� ����� ��������� ����������� ��������
		smod := "+" . Ru_En_Stats_Value(mod_name2)
	}
	Else {
		smod := Ru_En_Stats_Value(smod)
	}

	Return smod
}

;
Ru_En_Stats_Value(smod)
{
	ru_en_stats := Globals.Get("ru_en_stats")

	smod_en := ru_en_stats[smod]
	
	If(not smod_en) {
	
		; ��� ������ � ���������� - ��� ���� �������� # ������ ���������
		res := nameModNumToConst(smod)
		If (res.IsNameRuConst) {
			smod_en := ru_en_stats[res.nameModConst]
		}
		
		If(not smod_en) {	
			return smod
		}
	}
	
	; ��������� �� ������� ����� ������ ������� ��� �� ������
	; - ��� ������, ����� � ����� ������������ � ���������� �������� ���� ������������ ������ ����� ������, �.�. � ����� poetrade �� �����������
	StringReplace, smod_en, smod_en, `n, %A_Space%, All
	
	return smod_en
}

; ������������ ��� ���� � # � ��� ���� � �����������
nameModNumToConst(nameMod)
{
	nameModNum  := Globals.Get("nameModNum")
	nameModConst := nameModNum[nameMod]
	
	result := {}
	
	If(not nameModConst)
	{
		result.IsNameRuConst := false
		result.nameModConst := nameMod
		return result
	} 
	
	result.IsNameRuConst := true
	result.nameModConst := nameModConst
;console_log(nameMod, "nameMod")	
	return result
}

;������������ ������� ����� ��������� � ���������� �������
ConvertRuItemNameToEn(itemRu, currency=false)
{
	Global Item
	
	; ��������� � ��������� ������ - ���������
	If (not currency and RegExMatch(itemRu, "i)������� �����")) {
		return itemRu
	}
	
	;itemRu_ := Trim(RegExReplace(itemRu, "i)�������� ��������", ""))
	itemRu_ := Trim(StrReplace(itemRu, "�������� ��������", ""))
	
	If (Item.IsMap) {
		; ��� ����� "����� �����" ���  ����� ����������� �������, �.�. � ����������
		; �������� ����� ������������ ������ ����������� � ANSI ��������� - "o" � ����� ������� ������
		; �������������� ������ ������ �� ����������� � ����� � ANSI ����������
		;If (RegExMatch(itemRu_, "����� �����")) 
		IfInString, itemRu_, ����� �����
		{
			itemEn := "Maelstr" chr(0xF6) "m of Chaos"
			return itemEn
		}
	}
	
	; ���������� ������ ������ ��������� � ����������� ����������
	sameNameItem  := Globals.Get("sameNameItem")
	itemEn := ""
	If (Item.IsDivinationCard) {
		itemEn := sameNameItem.DivinationCard[itemRu_]
		If (itemEn) {
			return itemEn
		}
	}
	Else If (Item.IsGem) {
		itemEn := sameNameItem.Gem[itemRu_]
		If (itemEn) {
			return itemEn
		}
	}

	; ������ ������������ ������� ���� ��������� �� ������� ����� �� ���������� ���������
	nameItemRuToEn := Globals.Get("nameItemRuToEn")	
	
	itemEn := ""
	itemEn := nameItemRuToEn[itemRu_]
	
	If (not itemEn) {
		; ���� ������������ �� �������, ���������� ��� �� �������
		; �������� ���������� ���-�� ������������ ����� ������ - ������, � ������ ���� ������������ �������� �� ������� �������
		itemEn := itemRu
	}	
	
	return itemEn
}

; ��������������� ������� ����� ��������� �������� � ���������� �������
ConvertRuFlaskNameToEn(nameRu, baseNameRu)
{
	ruPrefSufFlask := TradeGlobals.Get("ruPrefSufFlask")
	
	affName := RegExReplace(nameRu, baseNameRu, "")
	
	; ��������� ������� �� ��������	
	If (RegExMatch(affName, "^([�-��-߸�]+) ([�-��-߸� ]+)*$", aff_name))
	{		
		pref := Trim(aff_name1)
		suff := Trim(aff_name2)
	} ; ������ �������
	Else If (RegExMatch(affName, "([�-ߨ][�-��]+)", aff_name)){
		pref := Trim(aff_name1)
		suff := ""
	} ; ������ �������
	Else If (RegExMatch(affName, "([�-��]+)", aff_name)){
		pref := ""
		suff := Trim(aff_name1)
	}
	
	
	;MsgBox full_ru:%nameRu% aff_ru:%affName% `npref: %pref% suff: %suff% 
	nameEn := ""
	nameEn := ruPrefSufFlask[pref] " " ConvertRuItemNameToEn(baseNameRu) " " ruPrefSufFlask[suff]
	;MsgBox %nameRu% `n%nameEn% 
	
	return nameEn
}


; ���� ���� � ����������� ������� ������� � ����� ����
; � ���������� ���������� �������� ���� �������� �� ���������
; ����� ���� ���������� ���������� ���������� �� � ���������� ��������
ConverNameModToValue(nameMod, name_ru)
{
	; ��������� �������� ���������
	RegExMatch(name_ru, ".*(\d+).*", constValue)
	; ��������� ��������� ��������� � ������
	RegExMatch(name_ru, "P).*(\d+).*", const)
	
	If (const and constValue) {
		; ������� �� ������������� ���� ���������
		nameMod := RegExReplace(nameMod, constValue1, "#",,1, constPos1)
		;console_log(name_ru, "name_ru")	
		;console_log(nameMod, "nameMod")	
	}

	return nameMod
}


; ������������� ���������� �������� ���������
InitNameEnItem()
{
	Global Item
	
	; ��������������� ������� ����� ��������� ��������
	If (Item.IsFlask and Item.RarityLevel = 2) {
		Item.Name_En := ConvertRuFlaskNameToEn(Item.Name, Item.BaseName)
	}
	Else {
		; ������������� �� ����������� ������� �������� � ����������
		Item.Name_En := ConvertRuItemNameToEn(Item.Name, Item.IsCurrency)
	}
	
	Item.BaseName_En := ConvertRuItemNameToEn(Item.BaseName, Item.IsCurrency)
}

; ������� ������������� ������� ������������ ��� �������� ������ � poe.trade
InitRuPrefSufFlask()
{
	FileRead, ruPrefSufFlask, %A_ScriptDir%\data_trade\ru\ruPrefSufFlask.json	
	TradeGlobals.Set("ruPrefSufFlask", JSON.Load(ruPrefSufFlask))
}

; ������� ������������� ������� ������������ ��������� � ��������� � ��������� ��������� �������� ������� ��������� ����������
InitBuyoutCurrencyEnToRu()
{
	buyoutCurrencyEnToRu := {}
	buyoutCurrencyEnToRu["blessed"]    := "����������� ����"
	buyoutCurrencyEnToRu["chisel"]     := "������"
	buyoutCurrencyEnToRu["chaos"]      := "������"
	buyoutCurrencyEnToRu["chromatic"]  := "������� ����"
	buyoutCurrencyEnToRu["alchemy"]    := "���� �������"
	buyoutCurrencyEnToRu["divine"]     := "������������ ����"
	buyoutCurrencyEnToRu["exalted"]    := "����������"
	buyoutCurrencyEnToRu["gcp"]        := "����� ���������"
	buyoutCurrencyEnToRu["jewellers"]  := "���� ������������"
	buyoutCurrencyEnToRu["alteration"] := "���� �������"
	buyoutCurrencyEnToRu["chance"]     := "���� �����"
	buyoutCurrencyEnToRu["fusing"]     := "���� ����������"
	buyoutCurrencyEnToRu["regret"]     := "���� ���������"
	buyoutCurrencyEnToRu["scouring"]   := "���� ��������"
	buyoutCurrencyEnToRu["regal"]      := "���� �����"
	buyoutCurrencyEnToRu["vaal"]       := "���� ����"
	buyoutCurrencyEnToRu["coin"]       := "����� �����������"
	buyoutCurrencyEnToRu["silver"]     := "���������� �����"

	TradeGlobals.Set("buyoutCurrencyEnToRu", buyoutCurrencyEnToRu)
}

; ������������ �������� ������ � ����������� �� �������
ConvertBuyoutCurrencyEnToRu(buycurEn)
{
	buyoutCurrencyEnToRu := TradeGlobals.Get("buyoutCurrencyEnToRu")
	buycurRu := buyoutCurrencyEnToRu[ buycurEn ]

/*
console.log("############Value: buyoutCurrencyEnToRu ############")
tmp := buyoutCurrencyEnToRu
console.log(tmp)
console.log("##############################")
*/	
	If (buycurRu){
		return buycurRu
	}
	Else {
		return buycurEn
	}
}

; ������� ������ �������� ���������� � ���������� �������
; var_ - ����������
; name_var - ��������� ��� ����������, ���� ����� ������� ����� ������� � ��������� ����� ���������
; console_log(var_, "var_")
console_log(var_, name_var)
{
	console.log("############Value: " name_var " ############")
	console.log(var_)
	console.log("##############################")
}

; �������� ������� ��� �������
testAdp(name_tst)
{
	dataTst := TradeGlobals.Get("VariableUniqueData")
	
	For index, uitem in dataTst {
		If (uitem.name = "Axiom Perpetuum") {
			console.log("############Value: uitem.mods.Length()_TST " name_tst " ############")
			tmp := uitem.mods.Length()
			console.log(tmp)
			console.log("##############################")
		}
		
	}
}