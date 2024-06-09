# Minecraft Server Tutorial

## VPC and Security group creation
Starting from your aws homepage enter **ec2** in the search bar and press the dashboard option.

Press the orange **launch instance** button then:
* In the **name** section enter **Minecraft-Server**.
* In the **application and OS images** section select the first Amazon Linux AMI and set the architecture to **64-bit(Arm)**.
* In the **instance type** section select the **t4g.small** instance type.

In the **Key pair (login)** section select **Create key pair** then:
* Enter a memorable name.
* Select **ED25519**.
* Select **.pem**.
* Press **create key pair**.

In the **Network settings** section press the **Edit** button Use the default vpc then:
* Under **Firewall (security groups)** select **Create security group**.
* Set name to **mc-security-group**.
* Set description as desired (we will be making this group have ports open for mc server and ssh).

We will need to set some inbound rules reliant on your region, find your cider region in [this](https://docs.aws.amazon.com/vpc/latest/userguide/aws-ip-ranges.html#aws-ip-download) list and note it for use.

In the **Inbound Security Group Rules** section:
* For the first rule:
    * Set the **Source type** to **Custom**.
    * In the **Source** box paste the cidr range for your region.
* Press the **Add security group rule** button.
* For the new rule:
    * Set the **Source Type** box to **Anywhere**.
    * In the **Port Range** box enter **25565**.
    * Set description to something that will remind you this allows mc connections.
* Add another rule:
    * replicate the first rule however for the **Source** box select **My IP**.

Launch the Instance.

## Server Setup

After creating the server press the link in the green box

Note the **Public IPv4 DNS** and **Public IPv4** addresses

### Connecting via ssh

1. Open an SSH client.
2. Locate your private key file downloaded earlier.
3. Run "chmod 400 "mc-server-key.pem"" if necessary, to ensure your key is not publicly viewable.

    

4. Connect to your instance using it**s **Public IPv4 DNS** from earlier.

Example:
    
    ssh -i "keyname.pem" ec2-user@[Public IPv4 DNS]

5. Enter "yes" and press enter.

Go to [this](https://www.minecraft.net/en-us/download/server) page and copy the link address of the download link.
### Server Magic
#### Downloading requirements
In the terminal run these commands in this order:

    sudo yum install -y java-21-amazon-corretto-headless
    sudo adduser minecraft
    sudo mkdir /opt/minecraft/
    sudo mkdir /opt/minecraft/server/
    cd /opt/minecraft/server
    
At this point we will now run the command to download the server from the link we got earlier.

   sudo wget pasted-link-here

#### Server files and script

We now need to generate server files for the server, run these commands:

    sudo chown -R minecraft:minecraft /opt/minecraft/
    sudo java -Xmx1024M -Xms1024M -jar server.jar nogui

After it fails you will have new files in your directory.

Open the **eula.txt** file with the command:
    
    sudo vim eula.txt 

Change the **false** to **true** and then press esc and enter ":wq" and press enter again.

Run the server again using the same java command as earlier. When it finishes initializing enter stop and press enter.

Now we want to garuntee ownership is set correctly, run these commands:

    sudo chown -R minecraft:minecraft /opt/minecraft
    sudo chmod -R 755 /opt/minecraft
    sudo mkdir -p /opt/minecraft/server/logs
    sudo chown -R minecraft:minecraft /opt/minecraft/server/logs
    sudo chmod -R 755 /opt/minecraft/server/logs

#### Set Minecraft server to run on reboot

We are now going to ensure that on a reboot the server restarts minecraft.

Run these commands:
    cd /etc/systemd/system/
    sudo touch minecraft.service

We then will now write our service using "sudo vim minecraft.service" it should look like this:

    [Unit]
    Description=Minecraft Server restart
    Wants=network-online.target
    After=network-online.target

    [Service]
    User=minecraft
    WorkingDirectory=/opt/minecraft/server
    ExecStart=/usr/bin/java -Xmx1024M -Xms1024M -jar server.jar nogui
    Restart=on-failure
    RestartSec=10
    TimeoutStartSec=600
    StandardInput=null

    [Install]
    WantedBy=multi-user.target

Now we make sure the system will use the service by running:

    sudo systemctl daemon-reload
    sudo systemctl enable minecraft.service
    sudo systemctl start minecraft.service

At this point the server should be able to be connected to on the minecraft client using the **Public IPv4 DNS** from earlier and the port 25565. Furthermore when the server is rebooted it will automatically begin starting the minecraft server back up. 

## My Questions:

>How do I update the version of Java I have installed? (on the first try I used outdated java so I updated the readme but sucked then)

A: To update the java version on this AMI one would do:
   
    sudo yum install -y java-XX-amazon-corretto-headless

Where XX is the new version you are updating to.

>What are the best options for server images to use?

A: This is somewhat subjective however I do feel that there are some better and worse options. Minecraft works well on
Linux and Windows servers but is often easier to set up background services in Linux so I feel that a Linux image is
best. I chose the Amazon image because it is the easiest to find support related to AWS on so.

>How much storage space should I allocate to the server?

A: This is somewhat subjective. 8GB is the lowest recomended due to the size of minecraft itself, however Minecraft 
world sizes are not static and will continue to grow as more chunks are rendered for the first time and have to be 
stored. My suggestion would be to start at 8 and since it is a cloud service grow if more is needed.