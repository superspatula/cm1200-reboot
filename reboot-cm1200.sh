retries=0
statuspage="http://192.168.100.1/RouterStatus.htm"
formpage="http://192.168.100.1/goform/RouterStatus?id="
formdata="buttonSelect=2&wantype=dhcp&enable_apmode=0&curlang=English"
userdata="admin:password"

# basic logging function
logit(){
    echo "$(date) - $1" >> ~/reboot-cm1200-log.txt
}

# retry 6 times, then give up
until [ $retries -ge 5 ]
do
    # log into router by requesting status page; requires using a cookie
    html=$(curl --silent --user $userdata $statuspage --anyauth --cookie /dev/null/)

    # verify that login succeeded
    if [[ $html != *"HTTP 401"* ]]
    then
        # pluck the url from the form action tag; it contains a session id
        sessionurl=$(xmllint --html --xpath "string(//html/body/form/@action)" 2>/dev/null - <<<"$html")

        # split the url on the "=" character and get the second element which is session id
        sessionid=$(echo $sessionurl | cut -d"=" -f2)

        # verify that the sessionid is numeric, otherwise, something went wrong
        if [[ $sessionid =~ ^[0-9]+$ ]]
        then
            logit "sessionid is $sessionid - executing reboot!"
            
            # issue reboot command and exit script
            curl --silent --user $userdata --anyauth --cookie /dev/null/ --data $formdata -X POST $formpage$sessionid
            break
        else
            logit "oops! sessionid is empty or non-numeric: $sessionid"
        fi
    else
        logit "oops! saw HTTP 401."
    fi

    ((retries+=1))
    logit "something went wrong. trying again! retries=$retries"
    sleep 1
done
