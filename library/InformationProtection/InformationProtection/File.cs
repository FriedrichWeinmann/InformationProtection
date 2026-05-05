using Microsoft.InformationProtection;
using Microsoft.InformationProtection.File;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PSFramework.Parameter;

namespace InformationProtection
{
    /// <summary>
    /// Wrapper around the MIP Tools specific to a single file.
    /// </summary>
    public class File : IDisposable
    {
        /// <summary>
        /// The name of the file
        /// </summary>
        public string Name { get; private set; }

        /// <summary>
        /// The full path of the file
        /// </summary>
        public string Path { get; private set; }

        /// <summary>
        /// The extension of the file
        /// </summary>
        public string Extension { get; private set; }

        /// <summary>
        /// The file handler, used to execute logic with
        /// </summary>
        public IFileHandler Handler {  get; private set; }

        /// <summary>
        /// The label object, containing all the details on the labels
        /// </summary>
        public ContentLabel Label { get; private set; }

        /// <summary>
        /// Is the file protected?
        /// </summary>
        public bool IsProtected { get; private set; }

        /// <summary>
        /// Name of the applied label (if any)
        /// </summary>
        public string LabelName { get; private set; }

        /// <summary>
        /// ID of the applied label (if any)
        /// </summary>
        public string LabelID { get; private set; }

        #region Capability Metadata
        /// <summary>
        /// Whether the file can be labeled without protection
        /// </summary>
        public bool CanBeUnprotected { get => MipHost.FileTypesIntegrated.Contains(Extension, StringComparer.OrdinalIgnoreCase); }

        /// <summary>
        /// What should the protected name of the file look like
        /// </summary>
        public string FileNameProtected
        {
            get
            {
                if (MipHost.FileTypesIntegrated.Contains(Extension, StringComparer.OrdinalIgnoreCase))
                    return Name;
                if (MipHost.FileTypesLimitedTo.ContainsKey(Extension))
                    return Name;
                if (MipHost.FileTypesLimitedFrom.ContainsKey(Extension))
                    return $"{Name.Substring(0, Name.Length - Extension.Length)}{MipHost.FileTypesLimitedFrom[Extension]}";
                if (String.Equals(Extension, ".pfile", StringComparison.OrdinalIgnoreCase))
                    return Name;
                return $"{Name}.pfile";
            }
        }

        /// <summary>
        /// What should the protected name of the file look like
        /// </summary>
        public string FileNameUnprotected
        {
            get
            {
                if (MipHost.FileTypesIntegrated.Contains(Extension, StringComparer.OrdinalIgnoreCase))
                    return Name;
                if (MipHost.FileTypesLimitedFrom.ContainsKey(Extension))
                    return Name;
                if (MipHost.FileTypesLimitedTo.ContainsKey(Extension))
                    return $"{Name.Substring(0, Name.Length - Extension.Length)}{MipHost.FileTypesLimitedTo[Extension]}";
                if (String.Equals(Extension, ".pfile", StringComparison.OrdinalIgnoreCase))
                    return Name.Substring(0, Name.Length - 6);
                return Name;
            }
        }
        #endregion Capability Metadata

        private MipSession _Session;

        /// <summary>
        /// Create a new file object from a path
        /// </summary>
        /// <param name="Path">The path to the file. Can be PowerShell-relative, will be resolved.</param>
        /// <param name="Session">The MIP Session used to perform labeling operations.</param>
        /// <exception cref="InvalidOperationException">Without connection, nothing can happen.</exception>
        public File(PathFileSingleParameter Path, MipSession Session)
        {
            if (null == Session.Context)
                throw new InvalidOperationException("Not yet connected! Call Session.Authenticate first!");
            _Session = Session;
            this.Path = Path;
            RefreshState();
        }
        /// <summary>
        /// Create a new file object from a path.
        /// </summary>
        /// <param name="Path">The path to the file. Can be PowerShell-relative, will be resolved.</param>
        /// <param name="Session">The MIP Session used to perform labeling operations.</param>
        public File(object Path, MipSession Session)
            :this(new PathFileSingleParameter(Path), Session)
        {

        }

        /// <summary>
        /// Reloads the label and protection status information
        /// </summary>
        /// <exception cref="InvalidOperationException">Can only be called if connected, has a path and the file exists</exception>
        public void RefreshState()
        {
            if (null == _Session.Context)
                throw new InvalidOperationException("Not yet connected! Call Authenticator.Authenticate first!");

            if (String.IsNullOrEmpty(Path))
                throw new InvalidOperationException("Cannot scan an empty path!");

            if (!System.IO.File.Exists(Path))
                throw new InvalidOperationException($"Path does not exist: {Path}!");

            Handler = Task.Run(async () => await _Session.FileEngine.CreateFileHandlerAsync(Path, Path, true)).Result;
            Label = Handler.Label;
            FileInfo info = new FileInfo(Path);
            Name = info.Name;
            Extension = info.Extension;
            if (Label == null)
                return;
            
            IsProtected = Label.IsProtectionAppliedFromLabel;
            LabelName = Label.Label.Name;
            LabelID = Label.Label.Id;
        }

        /// <summary>
        /// Apply the specified label
        /// </summary>
        /// <param name="LabelID">The ID of the label to apply</param>
        /// <param name="Destination">The destination path for the labeled file</param>
        /// <param name="Justification">The reason for the label change</param>
        /// <exception cref="ArgumentException">When source and destination path are equal, bad things happen.</exception>
        /// <param name="Method">Whether this is an administrative action (Privileged) or regular user action (Standard)</param>
        public void SetLabel(string LabelID, PathNewFileSingleParameter Destination, string Justification, AssignmentMethod Method)
        {
            if (Destination.ToString().ToLower() == Path.ToLower())
                throw new ArgumentException("Source and Destination cannot be the same!", "Destination");

            LabelingOptions labelingOptions = new LabelingOptions();
            labelingOptions.AssignmentMethod = Method;

            if (!String.IsNullOrEmpty(Justification))
            {
                labelingOptions.IsDowngradeJustified = true;
                labelingOptions.JustificationMessage = Justification;
            }

            Handler.SetLabel(_Session.FileEngine.GetLabelById(LabelID), labelingOptions, new ProtectionSettings());
            var result = Task.Run(async () => await Handler.CommitAsync(Destination)).Result;
        }

        /// <summary>
        /// Removes the assigned label
        /// </summary>
        /// <param name="Destination">The destination path for the labeled file</param>
        /// <param name="Justification">The reason for the label change</param>
        /// <param name="Method">Whether this is an administrative action (Privileged) or regular user action (Standard)</param>
        public void RemoveLabel(PathNewFileSingleParameter Destination, string Justification, AssignmentMethod Method)
        {
            LabelingOptions labelingOptions = new LabelingOptions();
            labelingOptions.AssignmentMethod = Method;

            if (!String.IsNullOrEmpty(Justification))
            {
                labelingOptions.IsDowngradeJustified = true;
                labelingOptions.JustificationMessage = Justification;
            }
            Handler.DeleteLabel(labelingOptions);
            var result = Task.Run(async () => await Handler.CommitAsync(Destination)).Result;
        }

        /// <summary>
        /// Reloads and reads the current label
        /// </summary>
        /// <returns>The label applied to the current file</returns>
        public ContentLabel GetLabel()
        {
            RefreshState();
            return Label;
        }

        /// <summary>
        /// Perform final cleanup
        /// </summary>
        public void Dispose()
        {
            Handler.Dispose();
        }
    }
}
