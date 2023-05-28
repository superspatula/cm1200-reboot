retries=0
statuspage="http://192.168.100.1/RouterStatus.htm"
formpage="http://192.168.100.1/goform/RouterStatus?id="
formdata="buttonSelect=2&wantype=dhcp&enable_apmode=0&curlang=English"
userdata="<your_username>:<your_password>"

until [ $retries -ge 5 ]
do
    #requires using a cookie
    html=$(curl --silent --user $userdata $statuspage --anyauth --cookie /dev/null/)

    if [[ $html != *"HTTP 401"* ]]
    then
        #pluck the url from the form action tag; it contains a session id
        sessionurl=$(xmllint --html --xpath "string(//html/body/form/@action)" 2>/dev/null - <<<"$html")

        #split the url on the "=" character and get the second element which is session id
        sessionid=$(echo $sessionurl | cut -d"=" -f2)

        if [[ $sessionid =~ ^[0-9]+$ ]]
        then
            echo "sessionid is $sessionid - execute reboot!"
            curl --silent --user $userdata --anyauth --cookie /dev/null/ --data $formdata -X POST $formpage$sessionid
            break
        else
            echo "oops! sessionid is empty or non-numeric: $sessionid"
        fi
    else
        echo "oops! saw HTTP 401."
    fi

    ((retries+=1))
    echo "something went wrong. trying again! retries=$retries"
    sleep 1
done
