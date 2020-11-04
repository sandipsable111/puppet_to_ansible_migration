#!/usr/bin/python3.6
import json
from json import JSONEncoder
import sys
import yaml


#Variables
instanceState='running'
properyFileName='inventoryConfig.yaml'

try:
   import boto3
except Exception as e:
    print(e)
    print(" Please rectify above exception and then try again")
    sys.exit(1)

#Class created to hold all groups and its host details
class AllGroups():
    #This method is used to set attributes to this class at runtime
    def addAttr(self,newAttr,attrValue):
        setattr(self, newAttr, attrValue)


# This is required to Serialize AllGroups class into JSON
class AllGroupsEncoder(JSONEncoder):
        def default(self, o):
            return o.__dict__


#Get All the distinct tag values present for perticular Key
def get_tag_values(ec2_ob,tagName,state):
    stateFilter={'Name': 'instance-state-name','Values': [state]}

    tags=[]
    for i in ec2_ob.instances.filter(Filters=[stateFilter]):
        for idx, tag in enumerate(i.tags, start=1):
            if(tag['Value'] not in tags and tag['Key']== tagName):
                tags.append(tag['Value'])
    return tags


#Get all list of hosts tagged under same tag value
def get_hosts(ec2_ob,tagName,tagValue,state):
    f ={"Name": "tag:"+tagName, "Values": [tagValue]}
    f1={'Name': 'instance-state-name','Values': [state]}

    hosts=[]
    for each_in in ec2_ob.instances.filter(Filters=[f,f1]):
         hosts.append(each_in.private_ip_address)

    return hosts

#Get all list of hosts tagged under same tag value
def read_inventory_configuration(properyFileName):
              with open(properyFileName) as f:
                   properties = yaml.load(f, Loader=yaml.FullLoader)
              return properties;

#This is the main method from here actual execution starts
def main():
        properties=read_inventory_configuration(properyFileName)

        tagKey= properties.get("tagKey")
        ansibleUser= properties.get("ansibleUser")
        regionName= properties.get("regionName")

        ec2_ob=boto3.resource("ec2",regionName)
        ec2_tags=get_tag_values(ec2_ob, tagKey, instanceState)
        all_hosts=AllGroups()


        #Grouping hosts by their tag value
        for tagValue in ec2_tags:
            db_group=get_hosts(ec2_ob,tagKey,tagValue,instanceState)
            host={
                    'hosts': db_group,
                    'vars':  {
                        'group_name': tagValue+' server group',
                        'ansible_user': ansibleUser
                        }
                    }
            all_hosts.addAttr(tagValue,host)
            #For loop ends here

        print (json.dumps(all_hosts,indent=3, cls=AllGroupsEncoder))

        return None

if __name__=="__main__":
    main()


