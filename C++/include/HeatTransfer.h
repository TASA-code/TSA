// #ifndef HEAT_TRANSFER
// #define HEAT_TRANSFER

/**
 * @class encapsulates the solution fields u, v, and h. With built in 
 *        functions SetInitialConditions and TimeIntegrates to solve the 2D 
 *        shallow-water equations
 * 
 */
class HeatTransfer {
    
    private: 

        /// define input variables and grid size
        double dt;
        int T;
        int Nx;
        int Ny;
        int ic;
        double temp;

        double alpha;

        double dx;
        double dy;
        int time_step;


        /// define solution fields
        double* TEMP;
        double* TEMP_next;

        int Index(int x, int y) const {
            return y * Nx + x;
        }



    public: 

        /// Takes parsed arguments, stores them and calculates various variables for performance improvements.
        void SetParameters(const double& arg_dt, const int& arg_T,
                        const int& arg_Nx, const int& arg_Ny,
                        const int& arg_ic, const double& arg_temp);
                            
        /// Set the Initial conditions defined from the question
        void SetInitialConditions();

        /// solve the equation by integrating through time till T
        void TimeIntegrate();

        /// Saves the result of the simulation to a .txt file.
        void SaveToFile();

        /// Deconstructor de-allocates all dynamically allocated memory.
        ~HeatTransfer();   

}; 


// #endif