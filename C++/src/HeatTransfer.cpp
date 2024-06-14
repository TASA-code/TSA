#include <chrono>
#include <cmath>
#include <fstream>
#include <iomanip>
#include <iostream>

#include "../include/HeatTransfer.h"
#include "/opt/homebrew/opt/openblas/include/cblas.h"


// Progress bar function
void Progress_Bar(int& iteration, const int& timestep){
    double progress = static_cast<double>(iteration) / timestep;
    const int barWidth = 55;
    int pos = static_cast<int>(barWidth * progress);

    std::cout << "[";
    for (int i = 0; i < barWidth; ++i) {
        if (i < pos)
            std::cout << "#";
        else if (i == pos)
            std::cout << "#";
        else
            std::cout << " ";
    }
    
    std::cout << "] " << std::fixed << std::setprecision(3)
                    << progress * 100.0 << "%\r";
    std::cout.flush();
}



/**
 * @brief Takes the command line input as parsed from the boost_option function
 * and store their values in the class. Allocates memory to solutions fields.
 *
 * @param arg_dt    The time step for integration
 * @param arg_T     The total time of integration
 * @param arg_Nx    The number of grid points for x
 * @param arg_Ny    The number of grid points for y
 * @param arg_ic    Options/Index for initial conditions
 */
void HeatTransfer::SetParameters(const double &arg_dt, const int &arg_T,
                                 const int &arg_Nx, const int &arg_Ny,
                                 const int &arg_ic, const double &arg_temp) {

    dt   = arg_dt;
    T    = arg_T;
    Nx   = arg_Nx;
    Ny   = arg_Ny;
    ic   = arg_ic;
    temp = arg_temp;  

    alpha = 9.7e-5;  



    dx = 0.05;
    Nx = Nx/dx;
    dy = 0.05;
    Ny = Ny/dy;


    TEMP      = new double[Nx * Ny];
    TEMP_next = new double[Nx * Ny];


    time_step = T / dt;



    // Printing values of all the parameters to the terminal.
    std::cout << std::endl;
    std::cout << "List of Commands Line Input for PDE:" << std::endl;
    std::cout << "    - dt       :  " << dt << std::endl;
    std::cout << "    - T        :  " << T << std::endl;
    std::cout << "    - Nx       :  " << Nx << std::endl;
    std::cout << "    - Ny       :  " << Ny << std::endl;
    std::cout << "    - option   :  " << ic << std::endl;
    std::cout << "    - Temp.    :  " << temp << std::endl;
    std::cout << std::endl;
};


/**
 * @brief Set the initial condition and boundary conditions. where u(x,y,0) =
 * v(x,y,0) = 0 and the h(x,y,0) = g(x,y). g(x,y) is the function prescribing
 * the initial surface height where the user can select options from the command
 * line input (option 1-4)
 *
 * Periodic boundary conditions are also used on all boundaries, so that waves
 * which propagate out of one of the boundaries re-enter on the opposite
 * boundary.
 *
 */
void HeatTransfer::SetInitialConditions() {
    // 'i' is used for the column index, 'j' for the row index,
    // 'Nx' is the number of colume and 'Ny' the number of rows.

    
    for (int i = 0; i < Nx; ++i) {
        for (int j = 0; j < Ny; ++j) {

        double x = i * dx;
        double y = j * dy;

        TEMP[i * Ny + j] = temp;
        // switch (ic) {
        //     case 1:
        //         TEMP[i * Ny + j] = 10.0 + exp(-(x - 50.0) * (x - 50.0) / 25.0);
        //         break;
        //     case 2:
        //         TEMP[i * Ny + j] = 10.0 + exp(-(y - 50.0) * (y - 50.0) / 25.0);
        //         break;
        //     case 3:
        //         TEMP[i * Ny + j] = 10.0 + exp(-((x - 50.0) * (x - 50.0) + (y - 50.0) * (y - 50.0)) / 25.0);
        //         break;
        //     case 4:
        //         TEMP[i * Ny + j] = 273.15 + exp(-(pow(x - 25.0, 2.0) + pow(y - 25.0, 2.0)) / 25.0) + exp(-(pow(x - 75.0, 2.0) + pow(y - 75.0, 2.0)) / 25.0);
        //         break;
        //     }
        // TEMP[i * Ny + j] = temp + 100*exp(-(pow(x - 5.0, 2.0) + pow(y - 5.0, 2.0)) / 25.0) + 70*exp(-(pow(x - 7.0, 2.0) + pow(y - 7.0, 2.0)) / 25.0);
        TEMP[ (Nx/2)*Ny + Nx/2 ] = 400;
        // int hp1_x = static_cast<int>(round(Nx / 2.0)) - 9;
        // int hp1_y = static_cast<int>(round(Ny / 2.0)) - 7;
        // TEMP[hp1_y * Nx + hp1_x] = 400.0;

        // int hp2_x = static_cast<int>(round(Nx / 2.0)) + 9;
        // int hp2_y = static_cast<int>(round(Ny / 2.0)) + 7;
        // TEMP[hp2_y * Nx + hp2_x] = 400.0;
        }
    }
};



/**
 * @brief For the time-integration using the 4th-order Runge-Kutta explicit
 * scheme.
 *
 */
void HeatTransfer::TimeIntegrate() {

    double xterm = 0.0; // Initialize xterm
    double yterm = 0.0; // Initialize yterm

    std::chrono::steady_clock::time_point begin = std::chrono::steady_clock::now();

    for (int t = 0; t < time_step; t++) {
        TEMP_next = TEMP; // Deep copy

        for (int i = 1; i < Nx - 1; ++i) {
            for (int j = 1; j < Ny - 1; ++j) {
                xterm = TEMP[j*Nx + (i-1)] - 2 * TEMP[j*Nx + i] + TEMP[j*Nx + (i+1)];
                yterm = TEMP[(j-1)*Ny + i] - 2 * TEMP[j*Ny + i] + TEMP[(j+1)*Ny + i];
                TEMP_next[i*Ny + j] = TEMP[i*Ny + j] + alpha * dt * (xterm / (dx * dx) + yterm / (dy * dy));
            }
        }

        cblas_dcopy(Nx * Ny, TEMP_next, 1, TEMP, 1); // Update TEMP with TEMP_next
        TEMP[ (Nx/2)*Ny + Nx/2 ] = 400;

        // Providing feedback to the user of how fast the program is running during execution.
        Progress_Bar(t, time_step);
    }


    std::cout << "\n\nFinished solving PDE (from t_i = 0 to t_f = T).\n"
                << std::endl;
    std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
    std::cout << "Time Spent (sec) = "
                << (std::chrono::duration_cast<std::chrono::microseconds>(end - begin).count()) / 1000000.0
                << std::endl;

};



void HeatTransfer::SaveToFile() {

    std::cout << "\nWriting output of simulation to file 'output.txt'." << std::endl;

    std::ofstream vOut("output.txt", std::ios::out | std::ios::trunc);

    // Checking that file opened successfully.
    if (vOut.is_open()) {
    // Writing solution row-by-row 
    // of storing matrices column-wise.
    for (int j = 0; j < Ny; ++j) {
        for (int i = 0; i < Nx; ++i) {
            vOut << i << " " << j << " " << TEMP[i * Ny + j] << std::endl;
        }
        vOut << std::endl; // Empty line after each row of points
    }
    } else {
    std::cout << "Did not open vOut successfully!" << std::endl;
    }

    vOut.close(); // Closing file.
    std::cout << "Finished writing to file.\n" << std::endl;
};



/**
 * @brief Performs clean up duties.
 */
HeatTransfer::~HeatTransfer() {

    // De-allocating memory.
    // delete[] TEMP;
    // delete[] TEMP_next;
}




