--Glamory Crystal
local s,id=GetID()
function s.initial_effect(c)
	--Level 1 Synchro Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.synop)
	c:RegisterEffect(e1)
	--Normal Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.sumcon)
	e2:SetCost(s.sumcost)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
	--Material Check
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	c:RegisterEffect(e3)
	--Send, Set, or do both
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.tgsetcondition)
	e4:SetTarget(s.tgsettg)
	e4:SetOperation(s.tgsetop)
	c:RegisterEffect(e4)
end
function s.tgsetcondition(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE) and e:GetHandler():GetFlagEffect(id)~=0 
end
function s.tgfilter(c)
	return c:IsMonster() and c:IsSetCard(0x36B0) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.setfilter(c)
	return c:IsCode(6120) and c:IsSSetable()
end
function s.tgsettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b1=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) 
	local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	local b3=b1 and b2 
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)},
		{b3,aux.Stringid(id,4)})
	e:SetLabel(op)
	local cat=0
	if op==1 or op==3 then
		cat=CATEGORY_TOGRAVE
		e:SetCategory(cat)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
	if op==2 or op==3 then
		cat=cat|CATEGORY_SEARCH
		e:SetCategory(cat)
	end
end
function s.tgsetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	local breakeff=false
	if op==1 or op==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
			breakeff=true
		end
	end
	if op==2 or op==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g1=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g1>0 then
			if breakeff then Duel.BreakEffect() end
			Duel.SSet(tp,g1)
			tc=g1:GetFirst()
			--Can be activated this turn
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e5)
		end
	end
end
function s.valfilter(c)
	return c:IsSetCard(0x36B0) or c:IsSetCard(0x36E2)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.valfilter,1,nil) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE|RESET_TEMP_REMOVE),0,1)
	end
end
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	local c=e:GetHandler()
	local sum=(sg-c):GetSum(Card.GetSynchroLevel,sc)
	if sum+c:GetSynchroLevel(sc)==lv then return true,true end
	return sc:IsSetCard(0x36B0) and (sum+1==lv),true
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
	Duel.ConfirmCards(1-tp,c)
	Duel.ShuffleHand(tp)
end
function s.sumfilter(c)
	return c:IsSetCard(0x36B0) and c:IsSummonable(true,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,g,1,tp,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end