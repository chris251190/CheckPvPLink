local function GenerateCheckPvPLink(name, realm, baseUrl)
    if name then
        -- If the realm is nil, use the player's own realm
        if not realm or realm == "" then
            realm = GetRealmName()
        end

        -- Insert a space when a realm consists of 2 words like this TwistingNether. So Twisting Nether would be Twisting Nether
        realm = realm:gsub("(%l)(%u)", "%1 %2")

        local region = GetCVar("portal"):lower()
        if region == "public-test" then
            region = "eu"
        end

        local link = string.format("%s/%s/%s/%s", baseUrl, region, realm, name)
        return link
    else
        print("Information currently not available for this target.")
        return nil
    end
end

local function ShowCopyDialog(link)
    if not link then
        return
    end

    if not CopyDialog then
        -- Create the frame
        CopyDialog = CreateFrame("Frame", "CopyDialog", UIParent, "BasicFrameTemplateWithInset")
        CopyDialog:SetSize(400, 200)
        CopyDialog:SetPoint("CENTER")
        CopyDialog:SetFrameStrata("DIALOG")

        -- Set the title
        CopyDialog.title = CopyDialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        CopyDialog.title:SetPoint("CENTER", CopyDialog.TitleBg, "CENTER", 0, 0)
        CopyDialog.title:SetText("CheckPvP Link")
        CopyDialog.title:SetTextColor(1, 1, 0) -- WoW yellow color

        -- Create the edit box
        CopyDialog.EditBox = CreateFrame("EditBox", nil, CopyDialog, "InputBoxTemplate")
        CopyDialog.EditBox:SetSize(360, 40)
        CopyDialog.EditBox:SetPoint("TOP", 0, -40)
        CopyDialog.EditBox:SetAutoFocus(false)
        CopyDialog.EditBox:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
        end)
        CopyDialog.EditBox:SetScript("OnKeyDown", function(self, key)
            if key == "C" and IsControlKeyDown() then
                -- Create the message
                if not CopyDialog.CopiedMessage then
                    CopyDialog.CopiedMessage = CopyDialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                    CopyDialog.CopiedMessage:SetPoint("BOTTOM", CopyDialog.CopyButton, "TOP", 0, 25)
                    CopyDialog.CopiedMessage:SetTextColor(1, 1, 0) -- WoW yellow color
                end
                CopyDialog.CopiedMessage:SetText("Copied Link!")
                CopyDialog.CopiedMessage:Show()

                -- Cancel any existing fade out animation
                if CopyDialog.CopiedMessage.fadeOutAnim then
                    CopyDialog.CopiedMessage.fadeOutAnim:Stop()
                end

                -- Fade out the message after 1 second
                CopyDialog.CopiedMessage.fadeOutAnim = CopyDialog.CopiedMessage:CreateAnimationGroup()
                local fadeOut = CopyDialog.CopiedMessage.fadeOutAnim:CreateAnimation("Alpha")
                fadeOut:SetFromAlpha(1)
                fadeOut:SetToAlpha(0)
                fadeOut:SetDuration(0.5)
                fadeOut:SetStartDelay(0.75)
                CopyDialog.CopiedMessage.fadeOutAnim:SetScript("OnFinished", function()
                    CopyDialog.CopiedMessage:Hide()
                end)
                CopyDialog.CopiedMessage.fadeOutAnim:Play()
            end
        end)

        -- Create the copy button
        CopyDialog.CopyButton = CreateFrame("Button", nil, CopyDialog, "GameMenuButtonTemplate")
        CopyDialog.CopyButton:SetSize(100, 40)
        CopyDialog.CopyButton:SetPoint("BOTTOM", 0, 20)
        CopyDialog.CopyButton:SetText("Copy")
        CopyDialog.CopyButton:SetNormalFontObject("GameFontNormalLarge")
        CopyDialog.CopyButton:SetHighlightFontObject("GameFontHighlightLarge")
        CopyDialog.CopyButton:SetScript("OnClick", function()
            CopyDialog.EditBox:HighlightText()
            CopyDialog.EditBox:SetFocus()

            -- Create the message
            if not CopyDialog.Message then
                CopyDialog.Message = CopyDialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                CopyDialog.Message:SetPoint("BOTTOM", CopyDialog.CopyButton, "TOP", 0, 25)
                CopyDialog.Message:SetTextColor(1, 1, 0) -- WoW yellow color
            end
            CopyDialog.Message:SetText("Selected Link. Copy with Ctrl + C.")
            CopyDialog.Message:Show()

            -- Cancel any existing fade out animation
            if CopyDialog.Message.fadeOutAnim then
                CopyDialog.Message.fadeOutAnim:Stop()
            end

            -- Fade out the message after 1 second
            CopyDialog.Message.fadeOutAnim = CopyDialog.Message:CreateAnimationGroup()
            local fadeOut = CopyDialog.Message.fadeOutAnim:CreateAnimation("Alpha")
            fadeOut:SetFromAlpha(1)
            fadeOut:SetToAlpha(0)
            fadeOut:SetDuration(0.5)
            fadeOut:SetStartDelay(0.75)
            CopyDialog.Message.fadeOutAnim:SetScript("OnFinished", function()
                CopyDialog.Message:Hide()
            end)
            CopyDialog.Message.fadeOutAnim:Play()
        end)
    end

    -- Set the link text
    CopyDialog.EditBox:SetText(link)
    CopyDialog:Show()
end

local function AddPvPCheckMenu(name, realm, infotext, checkPvPLink)
    local info = UIDropDownMenu_CreateInfo()
    info.text = infotext
    info.notCheckable = true
    info.func = function()
        local link = GenerateCheckPvPLink(name, realm, checkPvPLink)
        ShowCopyDialog(link)
    end
    if UIDROPDOWNMENU_MENU_LEVEL == 1 then
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
    end
end

local function AddTitle(pvpCheckText)
    if UIDROPDOWNMENU_MENU_LEVEL == 1 then
        local separator = UIDropDownMenu_CreateInfo()
        separator.text = ""
        separator.notCheckable = true
        separator.isTitle = true
        UIDropDownMenu_AddButton(separator, UIDROPDOWNMENU_MENU_LEVEL)

        local title = UIDropDownMenu_CreateInfo()
        local titleText = "|cffffd100" .. pvpCheckText .. "|r" -- WoW yellow color
        title.text = titleText
        title.notCheckable = true
        title.isTitle = true
        UIDropDownMenu_AddButton(title, UIDROPDOWNMENU_MENU_LEVEL)
    end
end

Menu.ModifyMenu("MENU_UNIT_SELF", function(ownerRegion, rootDescription, contextData)
    local characterName = contextData.accountInfo.gameAccountInfo.characterName
    local realmName = contextData.accountInfo.gameAccountInfo.realmName

    rootDescription:CreateDivider()
    rootDescription:CreateTitle("CheckPvP Link")
    rootDescription:CreateButton("Check PvP", function()
        ShowCopyDialog(GenerateCheckPvPLink(characterName, realmName, "https://check-pvp.fr"))
    end)
    rootDescription:CreateButton("Seramate", function()
        ShowCopyDialog(GenerateCheckPvPLink(characterName, realmName, "https://seramate.com"))
    end)
end)

Menu.ModifyMenu("MENU_UNIT_PLAYER", function(ownerRegion, rootDescription, contextData)
    local characterName = contextData.name
    local realmName = contextData.server

    rootDescription:CreateDivider()
    rootDescription:CreateTitle("CheckPvP Link")
    rootDescription:CreateButton("Check PvP", function()
        ShowCopyDialog(GenerateCheckPvPLink(characterName, realmName, "https://check-pvp.fr"))
    end)
    rootDescription:CreateButton("Seramate", function()
        ShowCopyDialog(GenerateCheckPvPLink(characterName, realmName, "https://seramate.com"))
    end)
end)

Menu.ModifyMenu("MENU_UNIT_PARTY", function(ownerRegion, rootDescription, contextData)
    local characterName = contextData.name
    local realmName = contextData.server

    rootDescription:CreateDivider()
    rootDescription:CreateTitle("CheckPvP Link")
    rootDescription:CreateButton("Check PvP", function()
        ShowCopyDialog(GenerateCheckPvPLink(characterName, realmName, "https://check-pvp.fr"))
    end)
    rootDescription:CreateButton("Seramate", function()
        ShowCopyDialog(GenerateCheckPvPLink(characterName, realmName, "https://seramate.com"))
    end)
end)

Menu.ModifyMenu("MENU_LFG_FRAME_SEARCH_ENTRY", function(contextData, rootDescription)
    local searchResultInfo = C_LFGList.GetSearchResultInfo(contextData.resultID)

    local characterName, realmName = strsplit("-", searchResultInfo.leaderName)

    rootDescription:CreateDivider()
    rootDescription:CreateTitle("CheckPvP Link")
    rootDescription:CreateButton("Check PvP", function()
        ShowCopyDialog(GenerateCheckPvPLink(characterName, realmName, "https://check-pvp.fr"))
    end)
    rootDescription:CreateButton("Seramate", function()
        ShowCopyDialog(GenerateCheckPvPLink(characterName, realmName, "https://seramate.com"))
    end)
end)

Menu.ModifyMenu("MENU_UNIT_BN_FRIEND", function(ownerRegion, rootDescription, contextData)
    local characterName = contextData.accountInfo.gameAccountInfo.characterName
    local realmName = contextData.accountInfo.gameAccountInfo.realmName

    if not characterName and not realmName then
        return
    end

    rootDescription:CreateDivider()
    rootDescription:CreateTitle("CheckPvP Link")
    rootDescription:CreateButton("Check PvP", function()
        ShowCopyDialog(GenerateCheckPvPLink(characterName, realmName, "https://check-pvp.fr"))
    end)
    rootDescription:CreateButton("Seramate", function()
        ShowCopyDialog(GenerateCheckPvPLink(characterName, realmName, "https://seramate.com"))
    end)
end)

Menu.ModifyMenu("MENU_LFG_FRAME_MEMBER_APPLY", function(contextData, rootDescription)
    local applicants = C_LFGList.GetApplicants()

    rootDescription:CreateDivider()
    rootDescription:CreateTitle("Check PvP Links")

    for i = 1, #applicants do
        local applicantData = C_LFGList.GetApplicantMemberInfo(applicants[i], 1)
        if applicantData then
            local characterName, realmName = strsplit("-", applicantData)
            if not realmName or realmName == "" then
                realmName = GetRealmName()
            end

            rootDescription:CreateButton(characterName .. "-" .. realmName, function()
                ShowCopyDialog(GenerateCheckPvPLink(characterName, realmName, "https://check-pvp.fr"))
            end)
        end
    end

    rootDescription:CreateDivider()
    rootDescription:CreateTitle("Seramate Links")

    for i = 1, #applicants do
        local applicantData = C_LFGList.GetApplicantMemberInfo(applicants[i], 1)
        if applicantData then
            local characterName, realmName = strsplit("-", applicantData)
            if not realmName or realmName == "" then
                realmName = GetRealmName()
            end

            rootDescription:CreateButton(characterName .. "-" .. realmName, function()
                ShowCopyDialog(GenerateCheckPvPLink(characterName, realmName, "https://seramate.com"))
            end)
        end
    end

end)

SLASH_CHECK1 = "/check"
SlashCmdList["CHECK"] = function()
    local name, realm = UnitName("target")
    if name then
        local link = GenerateCheckPvPLink(name, realm, "https://check-pvp.fr")
        ShowCopyDialog(link)
    else
        print("Information currently not available for this target.")
    end
end

SLASH_SERA1 = "/sera"
SlashCmdList["SERA"] = function()
    local name, realm = UnitName("target")
    if name then
        local link = GenerateCheckPvPLink(name, realm, "https://seramate.com")
        ShowCopyDialog(link)
    else
        print("No target selected or target is not a player.")
    end
end
