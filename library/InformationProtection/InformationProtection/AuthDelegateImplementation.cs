using Microsoft.InformationProtection;
using System;
using System.Collections.Generic;
using System.Management.Automation;

namespace InformationProtection
{
    /// <summary>
    /// Creates an authentication delegate, that is called by the SDK to get the entra tokens
    /// </summary>
    public class AuthDelegateImplementation : IAuthDelegate
    {
        private EntraAuthToken _AzureRightsManagement;
        private EntraAuthToken _MIPSyncService;

        /// <summary>
        /// Creates a new authentication delegate
        /// </summary>
        /// <param name="AzureRightsManagement">The EntraAuth token for the Azure Rights Management</param>
        /// <param name="MIPSyncService">The EntraAuth token for the Microsoft Information Protection Sync Service</param>
        public AuthDelegateImplementation(PSObject AzureRightsManagement, PSObject MIPSyncService)
        {
            _AzureRightsManagement = new EntraAuthToken(AzureRightsManagement);
            _MIPSyncService = new EntraAuthToken(MIPSyncService);
        }

        /// <summary>
        /// Give me a token for the requested resource!
        /// </summary>
        /// <param name="identity">The user that should be the source of the token. Ignored, since PowerShell assumes a single user connection per process.</param>
        /// <param name="authority">The authority owning the token. Handled externally in the EntraAUth token and ignored here.</param>
        /// <param name="resource">The resource we want the token for.</param>
        /// <param name="claims">Some claims we don't do</param>
        /// <returns>The token string to use.</returns>
        public string AcquireToken(Identity identity, string authority, string resource, string claims)
        {
            if (resource == "https://syncservice.o365syncservice.com/")
                return _MIPSyncService.GetToken();
            return _AzureRightsManagement.GetToken();
        }

        /// <summary>
        /// Return information about the application owning the token
        /// </summary>
        /// <returns>Some barebones application information</returns>
        public Microsoft.InformationProtection.ApplicationInfo GetAppInfo()
        {
            return new Microsoft.InformationProtection.ApplicationInfo()
            {
                ApplicationId = _AzureRightsManagement.AppID,
                ApplicationName = "Microsoft Information Protection (PowerShell)",
                ApplicationVersion = "1.0.0"
            };
        }

        /// <summary>
        /// Get information about the currently connected principal
        /// </summary>
        /// <returns>The currently connected principal (UPN or Object ID)</returns>
        public string GetPrincipal()
        {
            return _AzureRightsManagement.GetUser();
        }
    }
}
