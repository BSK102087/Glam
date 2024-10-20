--Glamory Ebony
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterSummonCode(6104),1,1,Synchro.NonTuner(s.matfilter),1,99)
	c:EnableReviveLimit()
	--Special Summon Procedure
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	--Set "Glamannequin Ebony"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	--Non-Tuner Level 1 or 5
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(s.synop)
	c:RegisterEffect(e5)
	--Return 1 banished Card
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_TOGRAVE)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,{id,1})
	e6:SetCondition(s.notquickcon)
	e6:SetTarget(s.rttg)
	e6:SetOperation(s.rtop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetCondition(s.quickcon)
	c:RegisterEffect(e7)
	--Special Summon Limit
	local e8=Effect.CreateEffect(c)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_SPSUMMON_SUCCESS)
	e8:SetCondition(s.regcon)
	e8:SetOperation(s.regop)
	c:RegisterEffect(e8)
end
function s.matfilter(c,val,scard,sumtype,tp)
	return c:IsSetCard(0x36B0,scard,sumtype,tp) or c:IsSetCard(0x36E2,scard,sumtype,tp)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA or (st&SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO
end
function s.hspfilter(c,tp,sc)
	return c:IsSetCard(0x36B0) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0 and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,6104) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.hspfilter,1,false,1,true,c,tp,nil,nil,nil,tp,c)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,s.hspfilter,1,1,false,true,true,c,tp,nil,false,nil,tp,c)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST+REASON_MATERIAL)
	g:DeleteGroup()
end
function s.setfilter(c)
	return c:IsCode(6125) and c:IsSSetable()
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
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	local c=e:GetHandler()
	local sum=(sg-c):GetSum(Card.GetSynchroLevel,sc)
	if sum+c:GetSynchroLevel(sc)==lv then return true,true end
	return sc:IsSetCard(0x36B0) and ((sum+1==lv) or (sum+5==lv)),true
end
function s.notquickcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,6129),0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,6129),0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.rtfilter(c)
	return c:IsAbleToGrave() or c:IsAbletoDeck()
end
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.rtfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	if #g>0 then
		local th=g:GetFirst()
		local sp=g:GetFirst()
		local op=0
		if th and sp then op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
		elseif sp then op=0
		else op=1 
		end
		if op==0 then
			Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
		else
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
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