#include <iostream>
#include <fstream>
#include <sstream>
#include <unordered_map>
#include <vector>
#include <string>
#include <algorithm>    
#include <cstdlib>
#include <map>
#include "generate_package_json.cpp"

std::string trim(const std::string& str) {
    size_t first = str.find_first_not_of(' ');
    size_t last = str.find_last_not_of(' ');
    return str.substr(first, (last - first + 1));
}

std::unordered_map<std::string, std::string> parseSimpleJson(const std::string& jsonString) {
    std::unordered_map<std::string, std::string> jsonMap;
    std::string::const_iterator it = jsonString.begin();
    while (it != jsonString.end()) {
        it = std::find(it, jsonString.end(), '"');
        if (it == jsonString.end()) break;
        auto keyStart = ++it;
        it = std::find(it, jsonString.end(), '"');
        if (it == jsonString.end()) break;
        std::string key = std::string(keyStart, it);

        it = std::find(it, jsonString.end(), ':');
        if (it == jsonString.end()) break;
        ++it;
        while (*it == ' ' || *it == '"') ++it;
        auto valueStart = it;
        if (*it == '{') {
            it = std::find(it, jsonString.end(), '}') + 1;
        }
        else if (*it == '[') {
            it = std::find(it, jsonString.end(), ']') + 1;
        }
        else {
            it = std::find(it, jsonString.end(), '"');
        }
        if (it == jsonString.end()) break;
        std::string value = std::string(valueStart, it);
        jsonMap[trim(key)] = trim(value);
        ++it;
    }
    return jsonMap;
}

// Function to parse nested JSON objects
std::string parseNestedJson(const std::string& jsonString) {
    std::string::const_iterator it = jsonString.begin();
    std::unordered_map<std::string, std::unordered_map<std::string, std::string>> valueMap;
    while (it != jsonString.end()) {
        // Find the next key
        it = std::find(it, jsonString.end(), '"');
        if (it == jsonString.end()) break;
        auto keyStart = ++it;
        it = std::find(it, jsonString.end(), '"');
        if (it == jsonString.end()) break;
        std::string key = std::string(keyStart, it);

        // Find the next value
        it = std::find(it, jsonString.end(), ':');
        if (it == jsonString.end()) break;
        ++it;
        while (*it == ' ' || *it == '"') ++it;
        auto valueStart = it;
        if (*it == '{') {
            // Handle nested object
            auto objectStart = it;
            it = std::find(it, jsonString.end(), '}') + 1;
            std::string nestedObject = std::string(objectStart, it);
            valueMap[trim(key)] = parseSimpleJson(nestedObject);
        }
        else if (*it == '[') {
            // Skip arrays for simplicity
            it = std::find(it, jsonString.end(), ']') + 1;
        }
        else {
            it = std::find(it, jsonString.end(), '"');
        }
        if (it == jsonString.end()) break;
    }
    return valueMap["default-registry"]["baseline"];
}

int main() {
    // int res1 = system("C:\\vcpkg\\vcpkg list > tmp.txt");
    // if (res1 == -1){
    //     cout<<"Command not executed"<<endl;
    // } else {
    //     cout<<"Command executed successfully"<<endl;
    // }
    std::string location = "vcpkg.json";
    //std::cout << "Input File location: " << std::endl;
    //std::cin >> location;
    const char* comm = "C:\\vcpkg\\vcpkg new --application";
    int res = system(comm);
    if (res != -1) {
        std::cout << "Command executed successfully" << std::endl;
    }

        // Open the JSON file
    std::ifstream inputFile("vcpkg-configuration.json");
    if (!inputFile.is_open()) {
        std::cerr << "Could not open the file!" << std::endl;
    }

    // Read the entire file content into a string
    std::stringstream buffer;
    buffer << inputFile.rdbuf();
    std::string jsonString = buffer.str();

    inputFile.close();
    // Parse the JSON string
    std::string value = parseNestedJson(jsonString);
    remove("vcpkg-configuration.json");

    std::cout << "VALUE: " << value << std::endl;

        // Arrays and further nested objects would need additional handling
    std::cout << "Note: Arrays and further nested objects are not fully handled in this example." << std::endl;
    genPackageJson(value, location);

    return 0;
}