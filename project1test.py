#Written by Tate Wilhelm, tatew@vt.edu

import subprocess
import sys

def main():
    #Read the name of the pascal source code file from command line arguments
    if len(sys.argv) != 2:
        print("ERROR: Please specify a .pas or .pp source file")
        return
    sourcefile = sys.argv[1]
    
    #Attepmt to compile the file, if successful it will be compiled to project1.exe
    print(f"Compiling {sourcefile} ...")
    print("#" * 40)
    compilefail = False
    fpc = subprocess.Popen(["fpc", "-oproject1.exe", sourcefile], stdout=subprocess.PIPE, universal_newlines=True, bufsize=0)

    #Forward the output from fpc to the console
    for ln in fpc.stdout:
        print(ln.strip())
        if "Fatal: Compilation aborted" in ln:
            compilefail = True

    #If compliation fails, tell the user and abort
    if compilefail:
        print("#" * 40)
        print("ERROR: compliation failed, see fpc errors above for details")
        return    

    print("#" * 40)

    #Open the test file 
    input = open("all_tests.txt")
    line = input.readline().strip()
    testnum = 0
    failednum = 0
    failed = []

    #While there's still a line in the test file, execute project1.exe, and feed it the first line of the test
    #Test cases are on odd numbered lines, expected output is on even numbered lines
    while line:
        pascal = subprocess.Popen("./project1.exe", stdin=subprocess.PIPE, stdout=subprocess.PIPE, universal_newlines=True, bufsize=0)
        pascal.stdin.write(line)
        pascal.stdin.close()

        #Read the actual output from project1.exe
        out = pascal.stdout.readline().strip()
        #Read the expected output line 
        sampleout = input.readline().strip()

        #Compare the actual output to the expected output.
        testnum += 1
        result = "PASSED"
        if (out != sampleout):
            result = "FAILED"
            failednum +=1
            failed.append(testnum)

        #Print the results 
        print(f"Test: {testnum} | Result: {result}")
        print(f"Input: {line}")
        print("Actual: ")
        print(out)
        print("Expected:")
        print(sampleout)
        print("-" * 40)

        #Read the next test line 
        line = input.readline().strip()

    #Print the summary 
    print("#" * 40)
    print("Summary:")
    print(f"Total Tests: {testnum}")
    print(f"Total Passes: {testnum - failednum}")
    print(f"Total Failures: {failednum}")
    print(f"Failed Tests: {failed}")

if __name__ == "__main__":
    main()