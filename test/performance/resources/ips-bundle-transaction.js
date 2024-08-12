import { SharedArray } from "k6/data";
import faker from "k6/x/faker";

const data = new SharedArray("IPS Bundle", function () {
  // All heavy work (opening and processing big files for example) should be done inside here.
  // This way it will happen only once and the result will be shared between all VUs, saving time and memory.
  const f = [JSON.parse(open("./ips-bundle-transaction.json"))];

  return f; // f must be an array
});

export const generateBundle = () => {
  let jsonString = JSON.stringify(data);

  // Bundle
  jsonString = replacePlaceholder(
    jsonString,
    "{{bundleUUID}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{bundleIdentifierUUID}}",
    faker.string.uuid()
  );

  // Patient
  jsonString = replacePlaceholder(
    jsonString,
    "{{patientLastName}}",
    faker.person.lastName()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{patientFirstName1}}",
    faker.person.firstName()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{patientFirstName2}}",
    faker.person.firstName()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{patientNamePrefix}}",
    faker.person.namePrefix()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{patientPhoneNumber}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{patientEmail1}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{patientEmail2}}",
    faker.string.uuid()
  );

  const genderCodes = ["male", "female", "other", "unknown"];
  jsonString = replacePlaceholder(
    jsonString,
    "{{patientGender}}",
    genderCodes[faker.number.intRange(0, genderCodes.length - 1)]
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{patientDOB}}",
    faker.time.date("yyyy-MM-dd")
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{PHN}}",
    faker.number.intRange(10000, 1000000)
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{PPN1}}",
    faker.number.intRange(10000, 1000000)
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{PPN2}}",
    faker.number.intRange(10000, 1000000)
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{DL1}}",
    faker.number.intRange(10000, 1000000)
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{DL2}}",
    faker.number.intRange(10000, 1000000)
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{NIC1}}",
    faker.number.intRange(1000000000, 9999999999)
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{NIC2}}",
    faker.number.intRange(1000000000, 9999999999)
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{SCN1}}",
    faker.number.intRange(1000000000, 9999999999)
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{SCN2}}",
    faker.number.intRange(1000000000, 9999999999)
  );

  // Practitioner
  jsonString = replacePlaceholder(
    jsonString,
    "{{practitionerLastName}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{practitionerFirstName1}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{practitionerFirstName2}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{practitionerNamePrefix}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{practitionerPhoneNumber}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{practitionerEmail}}",
    faker.string.uuid()
  );

  // Location
  jsonString = replacePlaceholder(
    jsonString,
    "{{locationPhoneNumber}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{locationEmail1}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{locationEmail2}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{LOCID}}",
    faker.number.intRange(10000, 1000000)
  );

  // Other resources ...
  const orgs = ["OrganizationExample"];
  const visitDate = "2024-03-01T15:30:32.000Z";
  jsonString = replacePlaceholder(jsonString, "{{timestamp}}", visitDate);
  jsonString = replacePlaceholder(
    jsonString,
    "{{patient}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{encounter}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{practitioner}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{location}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{condition}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{communication}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{obs-weight}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{allergies}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(jsonString, "{{organization}}", orgs[0]);
  jsonString = replacePlaceholder(
    jsonString,
    "{{medicationrequest}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{prescriptionId}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{medicationdispense}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{medicationadministration}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{procedure}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{imagingstudy}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{imagingservicerequest}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{generalreferralservicerequest}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{investigationsservicerequest}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{ipsreferraltask}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{procedureservicerequest}}",
    faker.string.uuid()
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{deviceinformation}}",
    faker.string.uuid()
  );

  jsonString = replacePlaceholder(
    jsonString,
    "{{ipsreferraltask-date}}",
    visitDate
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{imagingservicerequest-date}}",
    visitDate
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{imagingorder-date}}",
    visitDate
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{investigationsservicerequest-date}}",
    visitDate
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{investigationsorder-date}}",
    visitDate
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{generalreferralservicerequest-date}}",
    visitDate
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{medicationadministration-date}}",
    visitDate
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{imagingstudy-started}}",
    visitDate
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{medication-request-authored-on}}",
    visitDate
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{allergy-onset-date}}",
    visitDate
  );
  jsonString = replacePlaceholder(jsonString, "{{whenHandedOver}}", visitDate);
  jsonString = replacePlaceholder(
    jsonString,
    "{{performedDateTime}}",
    visitDate
  );
  jsonString = replacePlaceholder(jsonString, "{{obs-weight-date}}", visitDate);
  jsonString = replacePlaceholder(
    jsonString,
    "{{communicationSent}}",
    visitDate
  );
  jsonString = replacePlaceholder(
    jsonString,
    "{{conditionRecordedDate}}",
    visitDate
  );
  jsonString = replacePlaceholder(jsonString, "{{encounterDate}}", visitDate);
  jsonString = replacePlaceholder(
    jsonString,
    "{{device-system-id}}",
    faker.number.intRange(1000000000, 9999999999)
  );

  return JSON.parse(jsonString);
};

const replacePlaceholder = (jsonString, placeholder, value) => {
  const regex = new RegExp(placeholder, "g");
  return jsonString.replace(regex, value);
};
