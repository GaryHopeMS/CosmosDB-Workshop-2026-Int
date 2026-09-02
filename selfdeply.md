# Self-Deploy the Workshop Environment

Use Azure Cloud Shell in the Azure portal to deploy your own workshop environment.

## 1. Open Azure Cloud Shell

1. Go to the [Azure portal](https://portal.azure.com/) and sign in.
2. Select the **Cloud Shell** icon in the portal toolbar.
3. Select **PowerShell** when prompted.
4. If this is your first time using Cloud Shell, follow the prompts to create or select its storage.
5. Confirm that Cloud Shell is using the Azure subscription where you want to deploy the workshop resources.

## 2. Choose a resource group name and region

Before running the deployment, choose:

* A unique resource group name, such as `my-cosmos-workshop`.
* An Azure region available to your subscription, such as `westus3`.

If you do not have Contributor access at subscription scope, create the resource group first and ensure you have Owner access on it. The script deploys into an existing resource group at resource-group scope; subscription permissions are only required when the script must create the resource group.

Replace `<your-resource-group-name>` and `<your-region>` in the command below with your own values. Do not include the angle brackets.

## 3. Clone and deploy

Run these commands in the Cloud Shell PowerShell console:

```powershell
git clone https://github.com/GaryHopeMS/CosmosDB-Workshop-2026-Int
cd ./CosmosDB-Workshop-2026-Int/
./script/self-provisioning-user-environment.ps1 -NoFabric -Location <your-region> -ResourceGroupName <your-resource-group-name> -IsDocDB 0
```

For example:

```powershell
./script/self-provisioning-user-environment.ps1 -NoFabric -Location westus3 -ResourceGroupName my-cosmos-workshop -IsDocDB 0
```

## 4. Connect to the lab VM

A successful deployment returns output similar to this:

```text
Bastion shareable URL: https://bst-example.bastion.azure.com/api/shareable-url/00000000-0000-0000-0000-000000000000
VmAdminUsername: lab_exampleuser
VmAdminPassword: Example2*Password
```

Open the **Bastion shareable URL** in your browser. On the Bastion sign-in page, enter the **VmAdminUsername** and **VmAdminPassword** shown in your deployment output to connect to the workshop VM.

After signing in, accept the default options for all Windows first-time configuration prompts to finish setting up the desktop.

Open **Windows Terminal** in the lab VM, then create and open the `C:\data` directory:

```powershell
md \data
cd \data
git clone https://github.com/GaryHopeMS/CosmosDB-Workshop-2026-Int
cd .\CosmosDB-Workshop-2026-Int\
.\SetEnv.ps1
code .
```

Treat the generated password as sensitive information. Do not share it or commit it to source control.

The deployment creates billable Azure resources. When you finish the workshop, remove the resource group if you no longer need it.
