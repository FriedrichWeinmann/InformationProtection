using System;
using System.Management.Automation;
using System.Threading.Tasks;
using Microsoft.InformationProtection;
using Microsoft.InformationProtection.File;
using Microsoft.InformationProtection.Policy;
using Microsoft.InformationProtection.Protection;

namespace InformationProtection
{
    /// <summary>
    /// The main session host, owning all MIP operations in the process
    /// </summary>
    public static class MipHost
    {
        /// <summary>
        /// The top level MIP Engine Reference
        /// </summary>
        public static MipContext Context;

        /// <summary>
        /// The authentication implementation
        /// </summary>
        public static AuthDelegateImplementation Delegate;

        /// <summary>
        /// The main settings for file operations
        /// </summary>
        public static IFileProfile FileProfile;

        /// <summary>
        /// The engine that executes file operations based on its Profile
        /// </summary>
        public static IFileEngine FileEngine;

        /// <summary>
        /// The main settings for protection operations (encrypt / decrypt)
        /// </summary>
        public static IProtectionProfile ProtectionProfile;

        /// <summary>
        /// The engine that executes protection operations based on its Profile
        /// </summary>
        public static IProtectionEngine ProtectionEngine;

        /// <summary>
        /// The main settings for policy operations
        /// </summary>
        public static IPolicyProfile PolicyProfile;

        /// <summary>
        /// The engine that executes policy operations based on its Profile
        /// </summary>
        public static IPolicyEngine PolicyEngine;

        /// <summary>
        /// Setup Auhentication for the MIP SDK.
        /// The tokens must have previously been created using Connect-EntraService and the respective services needed.
        /// </summary>
        /// <param name="AzureRightsManagement">The EntraAuth token to interact with the https://aadrm.com/</param>
        /// <param name="MIPSyncService">The EntraAuth token to interact with the https://psor.o365syncservice.com</param>
        public static void Authenticate(PSObject AzureRightsManagement, PSObject MIPSyncService)
        {
            Delegate = new AuthDelegateImplementation(AzureRightsManagement, MIPSyncService);

            MipConfiguration mipConfiguration = new MipConfiguration(Delegate.GetAppInfo(), "mip_data", LogLevel.Trace, false);

            Context = MIP.CreateMipContext(mipConfiguration);

            StartFile();
            StartProtection();
            StartPolicy();
        }

        /// <summary>
        /// Initializes the File SDK Components
        /// </summary>
        public static void StartFile()
        {
            // Prepare Use of Component in MIP
            MIP.Initialize(MipComponent.File);

            StopFile();

            // Prepare Profile (Process-wide settings) and Engine (Executes based on settings)
            FileProfileSettings profileSettings = new FileProfileSettings(Context, CacheStorageType.InMemory, new ConsentDelegateImplementation());
            FileProfile = Task.Run(async () => await MIP.LoadFileProfileAsync(profileSettings)).Result;
            FileEngineSettings engineSettings = new FileEngineSettings(Delegate.GetPrincipal(), Delegate, "", "en-US");
            engineSettings.Identity = new Identity(Delegate.GetPrincipal());
            engineSettings.LoadSensitivityTypes = true;
            FileEngine = Task.Run(async () => await FileProfile.AddEngineAsync(engineSettings)).Result;
        }

        /// <summary>
        /// Cleans up the File SDK Components
        /// </summary>
        public static void StopFile()
        {
            if (FileEngine == null) return;
            if (FileProfile == null) return;

            Task.Run(async () => await FileProfile.DeleteEngineAsync(FileEngine.Settings.EngineId));
            FileEngine.Dispose();
            FileProfile.Dispose();
            FileEngine = null;
            FileProfile = null;
        }

        /// <summary>
        /// Initializes the Protection SDK Components
        /// </summary>
        public static void StartProtection()
        {
            // Prepare Use of Component in MIP
            MIP.Initialize(MipComponent.Protection);

            StopProtection();

            // Prepare Profile (Process-wide settings) and Engine (Executes based on settings)
            ProtectionProfileSettings profileSettings = new ProtectionProfileSettings(Context, CacheStorageType.InMemory, new ConsentDelegateImplementation());
            ProtectionProfile = MIP.LoadProtectionProfile(profileSettings);
            ProtectionEngineSettings engineSettings = new ProtectionEngineSettings(Delegate.GetPrincipal(), Delegate, "", "en-US");
            engineSettings.Identity = new Identity(Delegate.GetPrincipal());
            ProtectionEngine = ProtectionProfile.AddEngine(engineSettings);
        }

        /// <summary>
        /// Cleans up the Protection SDK Components
        /// </summary>
        public static void StopProtection()
        {
            if (ProtectionEngine == null) return;
            if (ProtectionProfile == null) return;

            Task.Run(async () => await ProtectionProfile.DeleteEngineAsync(ProtectionEngine.Settings.EngineId));
            ProtectionEngine.Dispose();
            ProtectionProfile.Dispose();
            ProtectionEngine = null;
            ProtectionProfile = null;
        }

        /// <summary>
        /// Initializes the Policy SDK Components
        /// </summary>
        public static void StartPolicy()
        {
            // Prepare Use of Component in MIP
            MIP.Initialize(MipComponent.Policy);

            StopPolicy();

            // Prepare Profile (Process-wide settings) and Engine (Executes based on settings)
            PolicyProfileSettings profileSettings = new PolicyProfileSettings(Context, CacheStorageType.InMemory);
            PolicyProfile = Task.Run(async () => await MIP.LoadPolicyProfileAsync(profileSettings)).Result;
            PolicyEngineSettings engineSettings = new PolicyEngineSettings(Delegate.GetPrincipal(), Delegate, "", "en-US");
            engineSettings.Identity = new Identity(Delegate.GetPrincipal());
            PolicyEngine = PolicyProfile.AddEngine(engineSettings);
        }

        /// <summary>
        /// Cleans up the Policy SDK Components
        /// </summary>
        public static void StopPolicy()
        {
            if (PolicyEngine == null) return;
            if (PolicyProfile == null) return;

            Task.Run(async () => await PolicyProfile.DeleteEngineAsync(PolicyEngine.Settings.Id));
            PolicyEngine.Dispose();
            PolicyProfile.Dispose();
            PolicyEngine = null;
            PolicyProfile = null;
        }

        /// <summary>
        /// Disconnects and disposes all MIP SDK context data
        /// </summary>
        public static void Disconnect()
        {
            StopFile();
            StopProtection();
            StopPolicy();

            Context.ShutDown();

            Context = null;
            Delegate = null;
        }
    }
}
