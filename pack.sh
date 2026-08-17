cd src

cd LambdaSharp
dotnet build -c Release
dotnet pack -c Release

cd ..
cd LambdaSharp.Tool
dotnet build -c Release
dotnet pack -c Release

cd ..
cd LambdaSharp.SimpleQueueService
dotnet build -c Release
dotnet pack -c Release

cd ..
cd LambdaSharp.Schedule
dotnet build -c Release
dotnet pack -c Release


cd ..
cp -r LambdaSharp/bin/Release/net8.0 ../../Deki/src/redist/LambdaSharp
cp -r LambdaSharp.Tool/bin/Release/net8.0 ../../Deki/src/redist/LambdaSharp.Tool
cp -r LambdaSharp.SimpleQueueService/bin/Release/net8.0 ../../Deki/src/redist/LambdaSharp.SimpleQueueService
cp -r LambdaSharp.Schedule/bin/Release/net8.0 ../../Deki/src/redist/LambdaSharp.Schedule