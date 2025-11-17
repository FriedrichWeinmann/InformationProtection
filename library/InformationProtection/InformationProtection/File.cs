using Microsoft.InformationProtection;
using Microsoft.InformationProtection.File;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using PSFramework.Parameter;

namespace InformationProtection
{
    /// <summary>
    /// Wrapper around the MIP Tools specific to a single file.
    /// </summary>
    public class File
    {
        /// <summary>
        /// The name of the file
        /// </summary>
        public string Name => System.IO.Path.GetFileName(Path);

        /// <summary>
        /// The full path of the file
        /// </summary>
        public string Path { get; private set; }

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

        /// <summary>
        /// Create a new file object from a path
        /// </summary>
        /// <param name="Path">The path to the file. Can be PowerShell-relative, will be resolved.</param>
        /// <exception cref="InvalidOperationException">Without connection, nothing can happen.</exception>
        public File(PathFileSingleParameter Path)
        {
            if (null == MipHost.Context)
                throw new InvalidOperationException("Not yet connected! Call Authenticator.Authenticate first!");
            this.Path = Path;
            RefreshState();
        }
        /// <summary>
        /// Create a new file object from a path.
        /// </summary>
        /// <param name="Path">The path to the file. Can be PowerShell-relative, will be resolved.</param>
        public File(object Path)
            :this(new PathFileSingleParameter(Path))
        {

        }

        /// <summary>
        /// Reloads the label and protection status information
        /// </summary>
        /// <exception cref="InvalidOperationException">Can only be called if connected, has a path and the file exists</exception>
        public void RefreshState()
        {
            if (null == MipHost.Context)
                throw new InvalidOperationException("Not yet connected! Call Authenticator.Authenticate first!");

            if (String.IsNullOrEmpty(Path))
                throw new InvalidOperationException("Cannot scan an empty path!");

            if (!System.IO.File.Exists(Path))
                throw new InvalidOperationException($"Path does not exist: {Path}!");

            Handler = Task.Run(async () => await MipHost.FileEngine.CreateFileHandlerAsync(Path, Path, true)).Result;
            Label = Handler.Label;
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
                labelingOptions.AssignmentMethod = AssignmentMethod.Standard;
            }

            Handler.SetLabel(MipHost.FileEngine.GetLabelById(LabelID), labelingOptions, new ProtectionSettings());
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
    }
}
