using Microsoft.InformationProtection;
using Microsoft.InformationProtection.File;
using Microsoft.InformationProtection.Policy;
using Microsoft.InformationProtection.Protection;
using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Text;
using System.Threading.Tasks;

namespace InformationProtection
{
    /// <summary>
    /// A single active MIP Session, containing all the information needed to execute MIP operations
    /// </summary>
    public class MipSession
    {
        /// <summary>
        /// Name of the account used for authentication
        /// </summary>
        public string Name { get => Delegate?.GetPrincipal(); }

        /// <summary>
        /// Email of the account used for authentication
        /// </summary>
        public string Email
        {
            get
            {
                if (!String.IsNullOrEmpty(_Email))
                    return _Email;
                return Delegate?.GetPrincipal();
            }
            set { _Email = value; }
        }
        private string _Email;

        /// <summary>
        /// The top level MIP Engine Reference
        /// </summary>
        public MipContext Context;

        /// <summary>
        /// The authentication implementation
        /// </summary>
        public AuthDelegateImplementation Delegate;

        /// <summary>
        /// The main settings for file operations
        /// </summary>
        public IFileProfile FileProfile;

        /// <summary>
        /// The engine that executes file operations based on its Profile
        /// </summary>
        public IFileEngine FileEngine;

        /// <summary>
        /// The main settings for protection operations (encrypt / decrypt)
        /// </summary>
        public IProtectionProfile ProtectionProfile;

        /// <summary>
        /// The engine that executes protection operations based on its Profile
        /// </summary>
        public IProtectionEngine ProtectionEngine;

        /// <summary>
        /// The main settings for policy operations
        /// </summary>
        public IPolicyProfile PolicyProfile;

        /// <summary>
        /// The engine that executes policy operations based on its Profile
        /// </summary>
        public IPolicyEngine PolicyEngine;

        /// <summary>
        /// Setup Auhentication for the MIP SDK.
        /// The tokens must have previously been created using Connect-EntraService and the respective services needed.
        /// </summary>
        /// <param name="AzureRightsManagement">The EntraAuth token to interact with the https://aadrm.com/</param>
        /// <param name="MIPSyncService">The EntraAuth token to interact with the https://psor.o365syncservice.com</param>
        /// <param name="LogPath">The place where the data nobody reads is written to.</param>
        public void Authenticate(PSObject AzureRightsManagement, PSObject MIPSyncService, string LogPath)
        {
            // Do a clean disconnect first - has no effect if not connected
            Disconnect();
            Delegate = new AuthDelegateImplementation(AzureRightsManagement, MIPSyncService);

            MipConfiguration mipConfiguration = new MipConfiguration(Delegate.GetAppInfo(), LogPath, LogLevel.Error, false, CacheStorageType.OnDiskEncrypted);

            Context = MIP.CreateMipContext(mipConfiguration);

            StartFile();
            StartProtection();
            StartPolicy();
        }

        /// <summary>
        /// Initializes the File SDK Components
        /// </summary>
        public void StartFile()
        {
            // Prepare Use of Component in MIP
            MIP.Initialize(MipComponent.File);

            StopFile();

            // Prepare Profile (Process-wide settings) and Engine (Executes based on settings)
            FileProfileSettings profileSettings = new FileProfileSettings(Context, CacheStorageType.InMemory, new ConsentDelegateImplementation());
            FileProfile = Task.Run(async () => await MIP.LoadFileProfileAsync(profileSettings)).Result;
            FileEngineSettings engineSettings = new FileEngineSettings(Delegate.GetPrincipal(), Delegate, "", "en-US");
            engineSettings.Identity = new Identity(Email, Name);
            engineSettings.LoadSensitivityTypes = true;
            FileEngine = Task.Run(async () => await FileProfile.AddEngineAsync(engineSettings)).Result;
        }

        /// <summary>
        /// Cleans up the File SDK Components
        /// </summary>
        public void StopFile()
        {
            if (FileEngine == null) return;
            if (FileProfile == null) return;

            Task.Run(async () => await FileProfile.DeleteEngineAsync(FileEngine.Settings.EngineId));
            // FileEngine.Dispose();
            // FileProfile.Dispose();
            FileEngine = null;
            FileProfile = null;
        }

        /// <summary>
        /// Initializes the Protection SDK Components
        /// </summary>
        public void StartProtection()
        {
            // Prepare Use of Component in MIP
            MIP.Initialize(MipComponent.Protection);

            StopProtection();

            // Prepare Profile (Process-wide settings) and Engine (Executes based on settings)
            ProtectionProfileSettings profileSettings = new ProtectionProfileSettings(Context, CacheStorageType.InMemory, new ConsentDelegateImplementation());
            ProtectionProfile = MIP.LoadProtectionProfile(profileSettings);
            ProtectionEngineSettings engineSettings = new ProtectionEngineSettings(Delegate.GetPrincipal(), Delegate, "", "en-US");
            engineSettings.Identity = new Identity(Email, Name);
            ProtectionEngine = ProtectionProfile.AddEngine(engineSettings);
        }

        /// <summary>
        /// Cleans up the Protection SDK Components
        /// </summary>
        public void StopProtection()
        {
            if (ProtectionEngine == null) return;
            if (ProtectionProfile == null) return;

            Task.Run(async () => await ProtectionProfile.DeleteEngineAsync(ProtectionEngine.Settings.EngineId));
            // ProtectionEngine.Dispose();
            // ProtectionProfile.Dispose();
            ProtectionEngine = null;
            ProtectionProfile = null;
        }

        /// <summary>
        /// Initializes the Policy SDK Components
        /// </summary>
        public void StartPolicy()
        {
            // Prepare Use of Component in MIP
            MIP.Initialize(MipComponent.Policy);

            StopPolicy();

            // Prepare Profile (Process-wide settings) and Engine (Executes based on settings)
            PolicyProfileSettings profileSettings = new PolicyProfileSettings(Context, CacheStorageType.InMemory);
            PolicyProfile = Task.Run(async () => await MIP.LoadPolicyProfileAsync(profileSettings)).Result;
            PolicyEngineSettings engineSettings = new PolicyEngineSettings(Delegate.GetPrincipal(), Delegate, "", "en-US");
            engineSettings.Identity = new Identity(Email, Name);
            PolicyEngine = PolicyProfile.AddEngine(engineSettings);
        }

        /// <summary>
        /// Cleans up the Policy SDK Components
        /// </summary>
        public void StopPolicy()
        {
            if (PolicyEngine == null) return;
            if (PolicyProfile == null) return;

            Task.Run(async () => await PolicyProfile.DeleteEngineAsync(PolicyEngine.Settings.Id));
            // PolicyEngine.Dispose();
            // PolicyProfile.Dispose();
            PolicyEngine = null;
            PolicyProfile = null;
        }

        /// <summary>
        /// Disconnects and disposes all MIP SDK context data
        /// </summary>
        public void Disconnect()
        {
            StopFile();
            StopProtection();
            StopPolicy();

            if (Context != null)
                Context.ShutDown();

            Context = null;
            Delegate = null;
        }
    }
}
