cask_bounces = class({})

function cask_bounces:IsPurgable() return false end
function cask_bounces:IsHidden() return false end
function cask_bounces:RemoveOnDeath() return false end
function cask_bounces:AllowIllusionDuplicate() return true end

function cask_bounces:GetTexture()
	return "witch_doctor_paralyzing_cask"
end

function cask_bounces:OnCreated()
	if IsClient() then return end
	self.bounce_base = 4
	self:StartIntervalThink(1)
end

function cask_bounces:OnRefresh()
	if IsClient() then return end
	self.bounce_base = self.bounce_base + 1
end

function cask_bounces:OnIntervalThink()
	self:SetStackCount(self.bounce_base + 4 * self:GetParent():GetLevel())
end