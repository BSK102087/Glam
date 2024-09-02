--Glamory Cinereous
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterSummonCode(6109),1,1,aux.FilterSummonCode(6110),1,1)
	c:EnableReviveLimit()
	--Special Summon Limit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.regcon)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	--Set "Glamannequin Cinereous"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	--Draw
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.notquickcon)
	e5:SetCost(s.cost)
	e5:SetTarget(s.target)
	e5:SetOperation(s.operation)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetCondition(s.quickcon)
	c:RegisterEffect(e6)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(s.reglimit)
	Duel.RegisterEffect(e2,tp)
end
function s.reglimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and sumtype&SUMMON_TYPE_SPECIAL==SUMMON_TYPE_SPECIAL
end
function s.setfilter(c)
	return c:IsCode(6126) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
		tc=g:GetFirst()
		--Can be activated this turn
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4)
	end
end
function s.notquickcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,6129),0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,6129),0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,false,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,1,1,false,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.filter(c,e)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	local tc=Duel.GetOperatedGroup():GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	if tc:IsSetCard(0x36B0) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local dg=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.GetControl(dg,tp)
	elseif tc:IsSetCard(0x36E2) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local dg=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.GetControl(dg,tp)
	else
	Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
	Duel.ShuffleHand(tp)
end

