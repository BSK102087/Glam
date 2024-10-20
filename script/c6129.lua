--Glamory Runway
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.target1)
	e2:SetOperation(s.operation1)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.check)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
	end)
	--Illusion Perk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(function(_,c) return c:IsSetCard(0x36B0) end)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetValue(s.glamfilter)
	c:RegisterEffect(e4)
end
function s.fsfilter(c)
	return c:IsFieldSpell() and c:IsCode(6130) and not c:IsForbidden()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.fsfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.fsfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		local tc=g:GetFirst()
		local fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,1-tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
function s.check(e,tp,eg,ep,ev,re,r,rp)
	local g1=Group.CreateGroup()
	local g2=Group.CreateGroup()
	for tc in aux.Next(eg) do
		if tc:IsFaceup() and tc:IsSetCard(0x36B0) then
			if tc:IsControler(0) then g1:AddCard(tc) else g2:AddCard(tc) end
		end
	end
	if #g1>0 then Duel.RaiseEvent(g1,EVENT_CUSTOM+id,re,r,rp,0,0) end
	if #g2>0 then Duel.RaiseEvent(g2,EVENT_CUSTOM+id,re,r,rp,1,0) end
end
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x36B0) and not c:IsType(TYPE_FIELD) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,e:GetHandler(),e,tp,c:GetCode())
end
function s.filter2(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and ((c:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g1=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetCode())
		if #g1>0 then
			if Duel.SpecialSummon(g1,0,tp,tp,true,false,POS_FACEUP)>0 then
				Duel.BreakEffect()
				Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end
function s.glamfilter(e,c)
	return c:IsSetCard(0x36B0)
end