ABSPATH=$(cd "$(dirname "$0")"; pwd)

git clone https://github.com/ChameleonBot/Common.git
git clone https://github.com/ChameleonBot/Config.git
git clone https://github.com/ChameleonBot/Models.git
git clone https://github.com/ChameleonBot/Services.git
git clone https://github.com/ChameleonBot/WebAPI.git
git clone https://github.com/ChameleonBot/RTMAPI.git
git clone https://github.com/ChameleonBot/Bot.git
git clone https://github.com/ChameleonBot/Sugar.git
git clone https://github.com/iosdevelopershq/Camille.git

mkdir -p _Development/Sources

ln -sf $ABSPATH/Common/Sources/Common $ABSPATH/_Development/Sources
ln -sf $ABSPATH/Config/Sources/Config $ABSPATH/_Development/Sources
ln -sf $ABSPATH/Models/Sources/Models $ABSPATH/_Development/Sources
ln -sf $ABSPATH/Services/Sources/Services $ABSPATH/_Development/Sources
ln -sf $ABSPATH/WebAPI/Sources/WebAPI $ABSPATH/_Development/Sources
ln -sf $ABSPATH/RTMAPI/Sources/RTMAPI $ABSPATH/_Development/Sources
ln -sf $ABSPATH/Bot/Sources/Bot $ABSPATH/_Development/Sources
ln -sf $ABSPATH/Sugar/Sources/Sugar $ABSPATH/_Development/Sources
ln -sf $ABSPATH/Camille/Sources/Camille $ABSPATH/_Development/Sources

cd _Development
curl -O https://raw.githubusercontent.com/iosdevelopershq/Camille/master/Development/Package.swift
swift package generate-xcodeproj
