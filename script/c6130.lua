--Glamannequin Amphitheatre
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsSetCard,0x36E2),
								desc=aux.Stringid(id,0), matfilter=s.matfilter,location=LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE})
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	c:RegisterEffect(e2)
	--Inactivatable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_INACTIVATE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetValue(s.effectfilter)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DISEFFECT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetValue(s.effectfilter)
	c:RegisterEffect(e4)
end
function s.filter(c)
	return c:IsFieldSpell() and c:IsCode(6129) and not c:IsForbidden()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		local tc=g:GetFirst()
		local fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,1-tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
function s.matfilter(c)
	return c:IsLocation(LOCATION_MZONE+LOCATION_HAND) and c:IsMonster()
end
function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and te:GetHandler():IsSetCard(0x36E2) and loc&LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED~=0
end