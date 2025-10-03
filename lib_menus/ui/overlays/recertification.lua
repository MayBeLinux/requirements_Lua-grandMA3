local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

local function NotCertifiedOrExpiredModulePresent()
    local retNotCeritified = false
    local retExpired = false
    local certificates = Root().certificates:Children()
    for key in pairs(certificates) do 
        if (certificates[key].IsOverallDeviceCertificate == false) and
            (certificates[key].PartOfOverallDevCert == false) and
            (certificates[key].Size > 0) then
            retNotCeritified = true;
        end
        if (certificates[key].CertificateIsVerified == "Expired") and --Enums.VerifyResult.Expired
            (certificates[key].Size > 0) then
            retExpired = true;
        end
    end
    return retNotCeritified, retExpired
end

signalTable.RecertificationMenuLoaded = function(caller,status,creator)
    local CertificationOverlay = caller
    HookObjectChange(signalTable.CertificatesChange,Root().certificates,my_handle:Parent(),CertificationOverlay);
    signalTable.CertificatesChange(caller, nil, CertificationOverlay);
end

signalTable.CertificatesChange = function(caller,signal,CertificationOverlay)
    local notCertifiedModules;
    local expiredModules;
    notCertifiedModules, expiredModules = NotCertifiedOrExpiredModulePresent();
    if expiredModules then
        CertificationOverlay.Content.CertificateWarningMsg.Text = "One or more of the connected modules require an online activation.\nPlease connect to the world server."
        CertificationOverlay.Content.CertificateWarningMsg.BackColor = Root().ColorTheme.ColorGroups.MessageCenter.NewWarningBackground
    elseif notCertifiedModules then
        CertificationOverlay.Content.CertificateWarningMsg.Text = "The overall device certificate cannot fully authenticate one or more internal modules.\nPlease contact your local distributor or MA Lighting Technical Support at support@malighting.com"
        CertificationOverlay.Content.CertificateWarningMsg.BackColor = Root().ColorTheme.ColorGroups.MessageCenter.NewAlertBackground
    else
        CertificationOverlay.Content.CertificateWarningMsg.Text = "All connected modules are fully authenticated."
        CertificationOverlay.Content.CertificateWarningMsg.BackColor = Root().ColorTheme.ColorGroups.MessageCenter.NewSpamBackground
    end

end
