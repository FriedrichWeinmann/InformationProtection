using System.Management.Automation;

namespace InformationProtection
{
    /// <summary>
    /// Wrapper Class around the EntraAuth token
    /// </summary>
    public class EntraAuthToken
    {
        /// <summary>
        /// The original token from EntraAuth
        /// </summary>
        public PSObject Token;

        /// <summary>
        /// The Application ID the token is for
        /// </summary>
        public string AppID { get => (string)Token.Properties["ClientID"].Value; }

        /// <summary>
        /// Creates a wrapper around an EntraAuth token C# code can interact with
        /// </summary>
        /// <param name="Token">Hopefully a genuine EntraAuth(tm) token object</param>
        public EntraAuthToken(PSObject Token)
        {
            this.Token = Token;
        }

        /// <summary>
        /// Get the latest token string, after making sure it hasn't expired
        /// </summary>
        /// <returns>An Entra access token.</returns>
        public string GetToken()
        {
            Token.Methods["GetHeader"].Invoke();

            return (string)Token.Properties["AccessToken"].Value;
        }

        /// <summary>
        /// Returns the user identifier of the associated token. Usually the UPN of the user or the object ID of the Service Principal.
        /// </summary>
        /// <returns>The UPN of the user or the object ID of the Service Principal</returns>
        public string GetUser()
        {
            PSObject tokenData = Token.Properties["TokenData"].Value as PSObject;
            if (tokenData.Properties["UPN"] != null)
                return (string)tokenData.Properties["UPN"].Value;

            return (string)tokenData.Properties["OID"].Value;
        }
    }
}
