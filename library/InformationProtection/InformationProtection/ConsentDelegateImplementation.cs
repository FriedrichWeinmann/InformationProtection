using Microsoft.InformationProtection;

namespace InformationProtection
{
    /// <summary>
    /// Always say "Yes"
    /// </summary>
    public class ConsentDelegateImplementation : IConsentDelegate
    {
        /// <summary>
        /// Ask whether it is ok (it always is)
        /// </summary>
        /// <param name="url">Some Url we are going to ignore</param>
        /// <returns>Always "Accept"</returns>
        public Consent GetUserConsent(string url)
        {
            return Consent.Accept;
        }
    }
}
