--Glamory Rose
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,s.mfilter,6,2)
	c:EnableReviveLimit()
	--Set or attach "Glamannequin Rose"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.satg)
	e1:SetOperation(s.saop)
	c:RegisterEffect(e1)
	--Extra Glamory attachment 
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.notquickcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.dattchtg)
	e3:SetOperation(s.dattchop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCondition(s.quickcon)
	c:RegisterEffect(e4)
	--Special Summon Limit
	local e7=Effect.CreateEffect(c)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetCondition(s.regcon)
	e7:SetOperation(s.regop)
	c:RegisterEffect(e7)
end
function s.mfilter(c,xyz,sumtype,tp)
	return c:IsSetCard(0x36B0,xyz,sumtype,tp) or c:IsSetCard(0x36E2,xyz,sumtype,tp)
end
function s.safilter(c)
	return c:IsCode(6128)
end
function s.dattchfilter1(c)
	return c:IsSetCard(0x36B0) and c:IsType(TYPE_XYZ)
end
function s.satg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.safilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.safilter,tp,LOCATION_DECK,0,1,nil) 
		and Duel.IsExistingTarget(s.dattchfilter1,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.dattchfilter1,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.saop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	Duel.Hint(HINT_SELECTMSG,tp,0)
	local g=Duel.SelectMatchingCard(tp,s.safilter,tp,LOCATION_DECK,0,1,1,nil,ft,e,tp)
	if #g>0 then
		local th=g:GetFirst() and c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e)
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
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(aux.Stringid(id,3))
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		else
			Duel.Overlay(tc,g,true) 
		end
	end
end
function s.notquickcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,6129),0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,6129),0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetOverlayCount()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) end
	c:RemoveOverlayCard(tp,ct,ct,REASON_COST)
end
function s.dattchfilter(c,xyzc,tp)
	return c:IsSetCard(0x36B0) and c:IsMonster() and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end
function s.dattchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return c:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.dattchfilter,tp,LOCATION_EXTRA,0,1,nil,c,tp)
	end
end
function s.dattchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local g=Duel.SelectMatchingCard(tp,s.dattchfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Overlay(c,tc,true)
		local code=tc:GetCode()
		if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e5:SetCode(EFFECT_CHANGE_CODE)
			e5:SetValue(code)
			c:RegisterEffect(e5)
			if not tc:IsType(TYPE_TRAPMONSTER) then
			c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
			end
		end
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e9=Effect.CreateEffect(e:GetHandler())
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e9:SetTargetRange(1,0)
	e9:SetReset(RESET_PHASE+PHASE_END)
	e9:SetTarget(s.reglimit)
	Duel.RegisterEffect(e9,tp)
end
function s.reglimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and sumtype&SUMMON_TYPE_SPECIAL==SUMMON_TYPE_SPECIAL
end