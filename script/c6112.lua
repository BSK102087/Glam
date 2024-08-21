--Glamory Hazel
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,s.mfilter,5,2)
	c:EnableReviveLimit()
	--Set or attach "Glamannequin Hazel"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.satg)
	e1:SetOperation(s.saop)
	c:RegisterEffect(e1)
	--Glamory attachment
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.notquickcon)
	e3:SetCost(s.dattchcost)
	e3:SetTarget(s.dattchtg)
	e3:SetOperation(s.dattchop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCondition(s.quickcon)
	c:RegisterEffect(e4)
end
function s.mfilter(c,xyz,sumtype,tp)
	return c:IsSetCard(0x36B0,xyz,sumtype,tp) or c:IsSetCard(0x36E2,xyz,sumtype,tp)
end
function s.notquickcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,6129),0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,6129),0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.dattchcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.dattchfilter(c,xyzc,tp)
	return c:IsSetCard(0x36B0) and c:IsMonster() and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end
function s.dattchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return c:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.dattchfilter,tp,LOCATION_DECK,0,1,nil,c,tp)
	end
end
function s.dattchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local g=Duel.SelectMatchingCard(tp,s.dattchfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Overlay(c,tc,true)
		if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e2:SetCode(EFFECT_CHANGE_CODE)
			e2:SetValue(tc:GetCode())
			c:RegisterEffect(e2)
		end
	end
end
function s.safilter(c)
	return c:IsCode(6127)
end
function s.satg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.safilter,tp,LOCATION_DECK,0,1,nil)
	end
end
function s.saop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	Duel.Hint(HINT_SELECTMSG,tp,0)
	local g=Duel.SelectMatchingCard(tp,s.safilter,tp,LOCATION_DECK,0,1,1,nil,ft,e,tp)
	if #g>0 then
		local th=g:GetFirst() and c:IsRelateToEffect(e)
		local sp=ft>0 and g:GetFirst():IsSSetable()
		local op=0
		if th and sp then op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
		elseif sp then op=0
		elseif th then op=1 
		else
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
		if op==0 then
			Duel.SSet(tp,g)
			tc=g:GetFirst()
			--Can be activated this turn
			local e5=Effect.CreateEffect(c)
			e5:SetDescription(aux.Stringid(id,3))
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e5)
		else
			Duel.Overlay(c,g,true)
		end
	end
end