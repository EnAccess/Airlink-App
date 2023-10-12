using System;
using System.Collections.Generic;
using System.Drawing;
using System.Text;

namespace Airlink.Services
{
    /*
    * Status Bar color change
    */
    public interface IEnvironment
    {
        void SetStautsBarColor(Color color, bool darkStatusBarTint);
    }
}
