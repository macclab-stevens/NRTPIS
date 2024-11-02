#!/opt/homebrew/bin/python3
#Script Used to graph 5G TDD slot patterns, and calculate symbol interfeerence based on radar charcterisitics. 
__author__ = "Eric Forbes"
__version__ = "0.1.0"
__license__ = "MIT"
import scipy.io
import pandas as pd
import numpy as np
import matplotlib
import matplotlib.pyplot as plt 
import matplotlib.patches as patches
from matplotlib.offsetbox import AnchoredText
from datetime import datetime
import sys
import os

def readSimLogFile(fileName):
    print("readSimLogFile()")
    mat = scipy.io.loadmat(fileName)
    
    #pull the relevant arrary from
    simLogs = mat['simulationLogs']
    simLogs = simLogs[0][0]['SchedulingAssignmentLogs'][0][0]
    
    #convert to DataFrame
    df = pd.DataFrame(simLogs)
    
    #Remove array chars
    for i in range(15):
        df[i] = df[i].astype(str).str.replace('[','')
        df[i] = df[i].astype(str).str.replace(']','')
        df[i] = df[i].astype(str).str.replace('\'','')
        df[i] = df[i].astype(str).str.replace(';',' ')
    
    #make new DF with the right column
    header = df.iloc[0]
    df  = pd.DataFrame(df.values[1:], columns=header)
    # print(header)
    df = df.rename(columns={'RBG Allocation Map':'RBG',
                            'Feedback Slot Offset (DL grants only)':'FdbkOffst',
                            'CQI on RBs':'CQIs'})
    
    #convert relevant columns to the right types
    toInts = ['RNTI','Frame','Slot','Start Sym', 'Num Sym', 'MCS', 'NumLayers', 'HARQ ID', 'NDI Flag', 'RV']
    #--INTS
    for i in toInts:
        df[i] = pd.to_numeric(df[i])
    toStrs = ['Grant type','Tx Type']
    #--Strings
    for i in toStrs:
        df[i] = df[i].astype(str)
    #--ARRAYS
    df['RBG'] = df['RBG'].astype(str).str.split(pat=' ')
    df['RBG'] = df['RBG'].apply(lambda lst: list(map(int, lst)))
    df['CQIs'] = df['CQIs'].astype(str).str.split(pat=' ')
    df['CQIs'] = df['CQIs'].apply(lambda lst: list(map(int, lst)))

    return df

def convertMATtoDIC(searchDir):
    directory = os.listdir(searchDir)
    for fname in directory:
        # print(fname)
        if "Metrics.mat" in fname:
            df = readSimLogFile(fname)
            csvFname = fname.rsplit( ".", 2 )[ 0 ] + ".csv"
            print(csvFname)
            df.to_csv(csvFname)
            print(fname)

def fileAnalysis(file):
    print(file)
    df = pd.read_csv(file)
    print(df)


def main():
    print("Start")
    # df = readSimLogFile('5UE_TTI2_241018-135922_simulationMetrics.mat')
    # convertMATtoDIC("./")
    fileAnalysis("./csv/5UE_TTI2_241018-135922_simulationMetrics.csv")

if __name__ == "__main__":
    """ This is executed when run from the command line """
    main()