#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <fstream>
#include <cstdlib>
#include <map>

// #define TEMP_FILE_NAME "temp.txt"
// #define MANIFEST_FILE_NAME "vcpkg.json"

using namespace std;

void createManifestFile(string baseline, string location) {
    ofstream manifest(location);
    remove("tmp.txt");

    if (manifest.is_open()) {
        manifest << "{" << endl;
        manifest << "\"version-string\": \"0.0.1\"," << endl;
        manifest << "\"dependencies\": [" << endl;
        manifest << "\"boost\",\"hiredis\",\"nlohmann-json\",\"spdlog\",\"fmt\",\"libpq\",\"librdkafka\",\"curl\"]," << endl;
        manifest << "\"overrides\": [" << endl;
        manifest << "{ \"name\": \"boost\", \"version\": \"1.83.0\" }," << endl;
        manifest << "{ \"name\": \"hiredis\", \"version\": \"1.0.0\" }," << endl;
        manifest << "{ \"name\": \"nlohmann-json\", \"version\": \"3.11.3\" }," << endl;
        manifest << "{ \"name\": \"spdlog\", \"version\": \"1.14.1\"}," << endl;
        manifest << "{ \"name\": \"fmt\", \"version\": \"10.2.1\" }," << endl;
        manifest << "{ \"name\": \"libpq\", \"version\": \"16.2\" }," << endl;
        manifest << "{ \"name\": \"librdkafka\", \"version\": \"2.3.0\" }," << endl;
        manifest << "{ \"name\": \"curl\", \"version\": \"8.7.1\" }" << endl;
        manifest << "]," << endl;
        manifest << "\"builtin-baseline\": \"" + baseline + "\"" << endl;
        manifest << "}" << endl;
    }
    manifest.close();
}

void genPackageJson(string value, string location) {
    map<string, string> mnfst;
    cout << "string: " << value << endl;
        // ifstream opFile("tmp.txt");
        // if(opFile.is_open()){
        //     cout<<"Open"<<endl;
        //     string line;

        //     while(getline(opFile, line)) {
        //         istringstream content(line);
        //         string firstCol, secondCol;
        //         string spllitedString = "";
        //         int delIdx;
        //         if (content >> firstCol){
        //             delIdx = firstCol.find(":");
        //             if (delIdx != string::npos)
        //                 spllitedString = firstCol.substr(0, delIdx);
        //             delIdx = firstCol.find("[");
        //             if (delIdx != string::npos)
        //                 spllitedString = firstCol.substr(0, delIdx);
        //             delIdx = firstCol.find("/");
        //             if (delIdx != string::npos)
        //                 spllitedString = firstCol.substr(0, delIdx);
        //             delIdx = firstCol.find("{");
        //             if (delIdx != string::npos)
        //                 spllitedString = firstCol.substr(0, delIdx);
        //             if (content >> secondCol){
        //                 if ((secondCol[0] >= 'A' and secondCol[0] <='Z') or (secondCol[0] >= 'a' and secondCol[0] <= 'z'))
        //                     mnfst[spllitedString] = "-1";
        //                 else
        //                     mnfst[spllitedString] = secondCol;
        //             }
        //         }

        //     }
        //     opFile.close();
        createManifestFile(value, location);

}