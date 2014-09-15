
def get_agent_id_for_machine(client, name):
    user_agents_url = "%s/user/agents" % (client.get_endpoint_for("cloudBackup"),)
    client.get(user_agents_url)

    for agent in client.response:
        if agent["MachineName"] == name:
            return agent["MachineAgentId"]

    return None


class Backup():

    def __init__(self, name, agent_id, email):
        self.name = name
        self.agent_id = agent_id
        self.email = email
        self.files = []

    def add_file(self, path):
        self.add_inclusion("File", path)

    def add_folder(self, path):
        self.add_inclusion("Folder", path)

    def add_inclusion(self, inclusion_type, inclusion_path):
        inclusion = {"FilePath": inclusion_path, "FileItemType": inclusion_type}
        self.files.append(inclusion)

    def manual_backup(self):
        return self.generate_backup_data(Frequency="Manually")


    def daily_backup(self, hour, minute, am_pm):
        return self.generate_backup_data(Frequency="Daily", StartTimeHour=hour, StartTimeMinute=minute, StartTimeAmPm=am_pm)


    def generate_backup_data(self, **kwargs):
        create_backup = {}
        create_backup["BackupConfigurationName"] = self.name
        create_backup["MachineAgentId"] = self.agent_id
        create_backup["IsActive"] = True
        create_backup["VersionRetention"] = 0
        create_backup["MissedBackupActionId"] = 1
        create_backup["StartTimeHour"] = None
        create_backup["StartTimeMinute"] = None
        create_backup["StartTimeAmPm"] = None
        create_backup["DayOfWeekId"] = None
        create_backup["HourInterval"] = None
        create_backup["TimeZoneId"] = "UTC"
        create_backup["NotifyRecipients"] = self.email
        create_backup["NotifySuccess"] = False
        create_backup["NotifyFailure"] = True
        create_backup["Inclusions"] =  self.files

        return dict(create_backup.items() + kwargs.items())

